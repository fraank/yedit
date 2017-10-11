var files_editor = {

  editor: false,

  file_open: false,

  init: function(el_selector, default_url, project){
    files_editor.element = el_selector;
    files_editor.default_url = default_url;
    files_editor.project = project;

    files_editor.editor = CodeMirror($(files_editor.element)[0], {
      value: "test",
      mode:  "javascript",
      lineNumbers: true,
      tabSize: 2,
      indentWithTabs: false
    });

    files_editor.editor.setSize("100%", "100%");

    $('#file-new-button').click(files_editor.new_save);

    // set Save Button Action
    $('#file-save-button').prop('disabled', true);
    $('#file-save-button').click(files_editor.save);
  },

  // on click new action
  new: function(folder) {
    $('#file_new_modal').modal('show');
    if(folder == "")
      folder = "/";
    $('#file_new_modal .input_field').val(folder);
  },

  // submit form for new file(s)
  new_save: function() {
    file_name = $('#file_new_modal .input_field').val();
    $.post( files_editor.default_url + "/create", {
      file: { name: file_name }
    }, function( data ) {
      
      direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      if(data.success == true) {
        files_tree.reload();
        files_editor.edit(file_name);
        $('#file_new_modal').modal('hide');
      }
    });
  },

  // edit or direct click / 
  edit: function(file_name){
    files_editor.file_open = file_name;

    $('#file-save-button').prop('disabled', false);

    $.post( files_editor.default_url + "/edit", {
      file: { name: file_name }
    }, function( data ) {
      files_editor.editor.setValue( data.content );
    });
  },

  save: function(file_name){
    if(files_editor.file_open && files_editor.file_open != "") {
      $.post( files_editor.default_url + "/save", {
        file: { 
          name: files_editor.file_open,
          content: files_editor.editor.getValue()
        }
      }, function( data ) {
        direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      });
    }
  },

  delete: function(file){ 
    $.post( files_editor.default_url + "/delete", {
      file: { 
        name: file
      }
    }, function( data ) {
      direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      files_tree.reload();
    });
  },

  rename: function(file){
    files_editor.edit(file);
    $('#rename_modal').modal('show');
    $('#rename_modal .input_field').val(file);
  }

};