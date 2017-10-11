var config_editor = {

  editor: false,
  current_config: false,
  data: "",

  init: function(el_selector, default_url){
    config_editor.element_selector = el_selector;
    config_editor.default_url = default_url;

    $('a.config_links').click(function(event) {
      config_editor.load($(event.target).data('ref').replace('#', ''));
      event.preventDefault();
    });

    $('a#editor_save').click(function(event) {
      config_editor.save();
      event.preventDefault();
    });

    $('a#editor_toggle').click(function(event){
      config_editor.toggle();
    });

    config_editor.load('_config.yml');
  },

  get_data_as_string: function(){
    return JSON.stringify(config_editor.data);
  },

  set_active: function(){
    $('a.config_links').parent('li').removeClass('active');
    $('a.config_links[data-ref="'+config_editor.current_config+'"]').parent('li').addClass('active');
  },

  load: function(load_config) {
    config_editor.current_config = load_config;
    config_editor.set_active();
    
    $.post( config_editor.default_url + "/edit", {
      file: load_config
    }).done(function( data ) {
      var opt = { 
          change: function(data) {
            config_editor.data = data;
          },
          propertyclick: function(path) {
            /* called when a property is clicked with the JS path to that property */
            console.log(path);
          }
      };
      /* opt.propertyElement = '<textarea>'; */ // element of the property field, <input> is default
      /* opt.valueElement = '<textarea>'; */  // element of the value field, <input> is default
      config_editor.data = data.config;
      $(config_editor.element_selector).jsonEditor(config_editor.data, opt);
    });

  },

  save: function(){
    //console.log(config_editor.get_data_as_string());
    $.post( config_editor.default_url + "/save", {
      file: config_editor.current_config,
      config: config_editor.get_data_as_string()
    }).done(function( data ) {
      direct_flash('success', config_editor.current_config, 'Saved');
    });
  },

  toggle: function(){
    var editor = $(config_editor.element_selector);
    editor.toggleClass('expanded');
    $('a#editor_toggle').text(editor.hasClass('expanded') ? 'Collapse' : 'Expand all');
  }
  
}