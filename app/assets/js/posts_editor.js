var posts_editor = {

  editor: false,
  file_open: false,
  config_data: false,
  config_editor_options: { 
    change: function(data) {
      posts_editor.config_data = data;
    }
  },
  
  init: function(el_selector, el_selector_config ,default_url){
    posts_editor.element = el_selector;
    posts_editor.config_selector = el_selector_config;
    posts_editor.default_url = default_url;

    // create mmarkdown editor
    posts_editor.editor = new SimpleMDE({
      element: $(posts_editor.element)[0],
      toolbar: [ "bold", "italic", "strikethrough", "heading", "heading-smaller", "heading-bigger", "|", "quote", "unordered-list", "ordered-list", "|", "link", "image", "table", "horizontal-rule", "code", "|", "clean-block", "|" , "preview", "side-by-side", "fullscreen", "guide"],
    });
    
    // create config editor
    $(posts_editor.config_selector).jsonEditor({}, posts_editor.config_editor_options);

    $('#post-add-button').click(function(){
      posts_editor.new()
    });

    $('#post-create-create-button').click(posts_editor.new_save);

    // set Save Button Action
    $('#save-button').prop('disabled', true);
    $('#save-button').click(posts_editor.save);
  },

  // on click new action
  new: function(folder) {
    $('#post_new_modal').modal('show');
    if(folder == "")
      folder = "/";
    $('#post_new_modal .input_field').val(folder);
  },

  // submit form for new file(s)
  new_save: function() {
    file_name = $('#post_new_modal .input_field').val();
    $.post( posts_editor.default_url + "/create", {
      post: { name: file_name }
    }, function( data ) {
      
      direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      if(data.success == true) {
        posts_tree.reload();
        posts_editor.edit(data.name);
        $('#post_new_modal').modal('hide');
      }
    });
  },

  // edit or direct click / 
  edit: function(file_name){
    posts_editor.file_open = file_name;

    $('#file-save-button').prop('disabled', false);

    $.post( posts_editor.default_url + "/edit", {
      post: { name: file_name }
    }, function( data ) {
      posts_editor.editor.value(data.content);
      posts_editor.config_data = data.config;
      $(posts_editor.config_selector).jsonEditor(posts_editor.config_data, posts_editor.config_editor_options);
    });
  },

  save: function(file_name){
    if(posts_editor.file_open && posts_editor.file_open != "") {
      content = posts_editor.editor.value();
      if(!content){
        content = "";
      }

      if(posts_editor.config_data == false || posts_editor.config_data == "false") {
        config = "";
      } else {
        config = JSON.stringify(posts_editor.config_data);
      }

      $.post( posts_editor.default_url + "/save", {
        post: { 
          name: posts_editor.file_open,
          content: content,
          config: config
        }
      }, function( data ) {
        direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      });
    }
  },

  delete: function(file){ 
    $.post( posts_editor.default_url + "/delete", {
      post: { 
        name: file
      }
    }, function( data ) {
      direct_flash(data.flashes[0].type, data.flashes[0].text, data.flashes[0].title);
      posts_tree.tree.reload();
    });
  },

  rename: function(file){
    posts_editor.edit(file);
    $('#rename_modal').modal('show');
    $('#rename_modal .input_field').val(file);
  }

};