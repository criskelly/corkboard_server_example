// make an object with a prototype

$(document).ready(function() {


  var Note = function(id) {
    this.baseUrl = '/note/';
    this.id = id;
    this.subject = '';
    this.content = '';
  };

  Note.prototype.fetch = function() {
    var this_ = this;
    return $.ajax({
      url: this.baseUrl + this.id,
      dataType: 'json',
      type: 'GET',
      context: this,
      success: function(data) {
        // debugger;
        this_.subject = data['subject'];
        this_.content = data['content'];
        console.log(this_.subject, this_.content);
        // display on HTML text area
        $('#txt-content').val(this_.content);
        $('#txt-subject').val(this_.subject);
      }, // 2xx response
      error: function(){
        location.reload();
      } // 4xx-5xx response
    });
  };

  Note.prototype.save = function(newSubject,newContent) {
    $.ajax({
      url: this.baseUrl + this.id,
      dataType: 'json',
      type: 'POST',
      context: this,
      data: JSON.stringify({
        subject : newSubject ,
        content : newContent
      }),
      success: function(data) {
        console.log(data);
      }, // 2xx response time
      error: function(){} // 4xx-5xx response time
    });
  };

  Note.prototype.create = function(newSubject,newContent) {
    $.ajax({
      url: this.baseUrl,
      dataType: 'json',
      type: 'PUT',
      context: this,
      data: JSON.stringify({
        subject : newSubject,
        content : newContent
      }),
      success: function() {
        console.log(data);
      },
      error: function(){}
    });
  };


  $('#submit_btn').click(function(e) {
    e.preventDefault();
    // when click, find value in text field
    var id = $('#testFetch').val();
    // create new Note with an ID
    var note = new Note(id);
    // call fetch on the new Note
    note.fetch();
    // display Note data on page
    console.log(note);
  });
    // choose and change the id
  $('#notesUp').change(function() {
      // get current value of notesUp
      var this_id = $(this).val();
      // get the current note (which is an object in the array)
      new Note(this_id).fetch().done(function() {
        // take the subject from current object
        // put the subject in the subject box
        var this_subject = this.subject;
        // take the content from current object
        // put the content in the subject box
        var this_content = this.content;
        // console.log(this_note);
        console.log(this_content);
        console.log(this_subject);
      }); // end done
    }); // end notesUP change
}); // end ready

function fetchAll() {
  $.ajax({
      url: '/note',
      dataType: "json",
      type: "GET",
      context: this,
      success: function (data) {
        // create an array of IDs???
        console.log(data);
      },
      error: function () {

      }
    });
  }

function displayNotes() {
  $.ajax({
    url: '/note',
    dataType: "json",
    type: "GET",
    context: this,
    success: function (data) {
      $(data).each(function(index, note) {
        $('#notesUp').append('<option>' + note['id'] + '</option>');
      });
    },
    error: function () {
    }
  });
}

displayNotes();
fetchById(5);