$(function() {
  var $console= $('#console');
  var instance = $console.console({
    autofocus: true,
    commandHandle: function(line, report) {
      $.ajax({
        url: $console.data('remote-path'),
        type: 'PUT',
        dataType: 'json',
        data: { input: line },
        success: function(response) {
          instance.promptLabel(response.prompt);
        }
      });
    }
  });
});
