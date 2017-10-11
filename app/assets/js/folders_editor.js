var folders_editor = {
  
  init: function(){
    // set Save Button Action
    $('#folder-new-button').click(folders_editor.new_save);
  },

  new: function(folder){
    $('#folder_new_modal').modal('show');
    if(!folder || folder == "")
      folder = "/";
    $('#folder_new_modal .input_field').val(folder);
  },

  new_save: function(){
    folder_name = $('#folder_new_modal .input_field').val();
    
    if(folder_name && folder_name != ""){
      $.post( fileeditor.default_url + "/create", {
        folder: { 
          name: folder_name
        }
      }, function( data ) {
        direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
        files_tree.reload();
        $('#folder_new_modal').modal('hide');
      });
    }
  },

  delete: function(folder){
    $.post( fileeditor.default_url + "/delete", {
      folder: { 
        name: folder
      }
    }, function( data ) {
      direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      files_tree.reload();
    });
  },

  rename: function(folder){
    $('#rename_modal').modal('show');
    $('#rename_modal .input_field').val(folder);
  }

}