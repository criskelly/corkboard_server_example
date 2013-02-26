// make an object with a prototype

$(document).ready(function() {


  var Note = function(id) {
    this.baseUrl = '//localhost:9292/note/';
    this.id = id;
    this.subject = '';
    this.content = '';
  };

  Note.prototype.fetch = function() {
    $.ajax({
      url: this.baseUrl + this.id,
      dataType: 'json',
      type: 'GET',
      context: this,
      success: function(data) {
        console.log(data);
      }, // 2xx response time
      error: function(){} // 4xx-5xx response time
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
      url: this.baseUrl + this.id,
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

  var a = new Note(2);
    a.fetch();
  var b = new Note(4);
    b.save("Desert","Sand fight!");
    b.fetch();
  var c  = new Note(8);
    c.create("Ocean","Shark fight!");
    c.fetch();



});

