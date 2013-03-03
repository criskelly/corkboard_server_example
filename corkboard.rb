require 'rubygems'
require 'sinatra'
require 'json'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

if development? # This is set by default, override with `RACK_ENV=production rackup`
  require 'sinatra/reloader'
  require 'debugger'
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
  Debugger.settings[:reload_source_on_change] = true
end

# TODO:
# . logging
# . media types testing
# . put the database somewhere else
# . GET a range
# . multi-user with authentication

configure :development, :production do
  set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/corkboard.sqlite3"
end
configure :test do
  set :datamapper_url, "sqlite3://#{File.dirname(__FILE__)}/corkboard-test.sqlite3"
end

DataMapper.setup(:default, settings.datamapper_url)

class Note
  include DataMapper::Resource

  Note.property(:id, Serial)
  Note.property(:subject, Text, :required => true)
  Note.property(:content, Text, :required => true)
  Note.property(:created_at, DateTime)
  Note.property(:updated_at, DateTime)

  def to_json(*a)
   {
      'id'      => self.id,
      'subject' => self.subject,
      'content' => self.content,
      'date'    => self.updated_at
   }.to_json(*a)
  end
end

get '/' do
  notes = Note.all.take 10
  return [200, {'Content-Type' => 'text/html'}, [notes.to_json] ]
end

DataMapper.finalize
Note.auto_upgrade!

def jsonp?(json)
  if params[:callback]
    return("#{params[:callback]}(#{json})")
  else
    return(json)
  end
end

# allows data to be retrieved via 'GET' statements      ##########
get '/note/:id' do
  note = Note.get(params[:id])

# if note is nil (has no content), return a 404 ERROR,  ##########
# otherwise, return a 200 (allows action)               ##########
  if note.nil?
    return [404, {'Content-Type' => 'application/json'}, ['']]
  end

  return [200, {'Content-Type' => 'application/json'}, [jsonp?(note.to_json)]]
end

# download all notes

get '/note' do
  note = Note.all.to_a

  if note.nil?
    return [404, {'Content-Type' => 'application/json'}, ['Does not exist']]
  end

  return [200, {'Content-Type' => 'application/json'}, [jsonp?(note.to_json)]]
end

# allows data INTO the database via 'PUT' statements    ##########
put '/note/' do
  # Request.body.read is destructive, make sure you don't use a puts here.
  data = JSON.parse(request.body.read)

  # Normally we would let the model validations handle this but we don't
  # have validations yet so we have to check now and after we save.
# If any of these conditions is true, return a 406      ##########
  if data.nil? || data['subject'].nil? || data['content'].nil?
    return [406, {'Content-Type' => 'application/json'}, ['']]
  end

  note = Note.create(
              :subject => data['subject'],
              :content => data['content'],
              :created_at => Time.now,
              :updated_at => Time.now)

  # PUT requests must return a Location header for the new resource
  if note.save
    return [201, {'Content-Type' => 'application/json', 'Location' => "/note/#{note.id}"}, [jsonp?(note.to_json)]]
  else
    return [406, {'Content-Type' => 'application/json'}, ['']]
  end
end

post '/note/:id' do
  # Request.body.read is destructive, make sure you don't use a puts here.
  # JSON turns the request (the body) into a hash
  data = JSON.parse(request.body.read)
  if data.nil?
    return [406, {'Content-Type' => 'application/json'}, ['']]
  end

  note = Note.get(params[:id])
  if note.nil?
    return [404, {'Content-Type' => 'application/json'}, ['']]
  end

  %w(subject content).each do |key|
    if !data[key].nil? && data[key] != note[key]
      note[key] = data[key]
      note['updated_at'] = Time.now
    end
  end

  if note.save then
    return [200, {'Content-Type' => 'application/json'}, [jsonp?(note.to_json)]]
  else
    return [406, {'Content-Type' => 'application/json'}, ['']]
  end
end

# Remove a note entirely
# delete method hack might be required here!
delete '/note/:id' do
  note = Note.get(params[:id])
  if note.nil?
    return [404, {'Content-Type' => 'application/json'}, ['']]
  end

  if note.destroy then
    return [204, {'Content-Type' => 'application/json'}, ['']]
  else
    return [500, {'Content-Type' => 'application/json'}, ['']]
  end
end
