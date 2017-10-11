function direct_flash(type, text, title = "") {
  var flash_str = '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>';
  if(title != '') {
    flash_str += '<h4>' + title + '</h4>';
  }
  flash_str += text;
  
  $('<div />',{ style:'display:none', class:'alert alert-' + type + ' alert-dismissible' })
    .html(flash_str)
    .appendTo($('#direct-flashes'))
    .fadeIn(500, 
      function(){
        var el = $(this);
        setTimeout(function(){
          el.fadeOut(500,
            function(){
                $(this).remove();
            });
        }, 5000);
    });
}

$(".ajaxform").submit(function(e) {
  var postData = $(this).serializeArray();
  var formURL = $(this).attr("action");
  $.ajax({
    url : formURL,
    type: "POST",
    data : postData,
    success:function(data, textStatus, jqXHR) {
      if(data && data.flashes && data.flashes.length > 0) {
        $.each(data.flashes, function( index, flash ) {
          direct_flash(flash.type, flash.text, flash.title);
        });
      }
    },
    error: function(jqXHR, textStatus, errorThrown) {

    }
  });
  e.preventDefault(); // stop default action
  $(e).unbind(); // stop multiple form submit.
});