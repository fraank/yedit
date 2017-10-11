var posts_tree = {

  init: function(el_selector, session_identifier, default_url) {

    posts_tree.element = el_selector;
    posts_tree.session_identifier = session_identifier;
    posts_tree.default_url = default_url;

    // make empty session
    if(!sessionStorage.getItem(posts_tree.session_identifier)) {
      sessionStorage.setItem(posts_tree.session_identifier, "");
    }

    // init tree
    posts_tree.load_tree();
    posts_tree.load_contextmenu();

  },

  // do a hard reset of the whole tree!
  reset: function() {
    sessionStorage.removeItem(posts_tree.session_identifier);
  },

  reload: function(){
    $(posts_tree.element).empty();
    posts_tree.load_tree();
  },

  // ajax load from data and initialize tree
  load_tree: function(){
    $.ajax({
      url: posts_tree.default_url
    }).done(function( data ) {
      posts_tree.build_nodes($(posts_tree.element), [{
        name: "",
        children: data.tree.children
      }]);
    });
  },

  // extecute and route clicks from the tree
  click: function(key, options) {
    identifier = $(options.$trigger).attr('href').replace('#', '');
    parts = key.split("_");
    if(parts[0] == 'folder') {
      folders_editor[parts[1]](identifier);
    } else if(parts[0] == 'file') {
      posts_editor[parts[1]](identifier);
    }
  },

  load_contextmenu: function(){
    // context menu for folder
    $.contextMenu({
      selector: '.treefolder-context-menu', 
      callback: function(key, options) {
        posts_tree.click(key, options);
      },
      items: {
        "file_new"         : { name: "New File", icon: "fa-file-o" },
      }
    });

    $.contextMenu({
      selector: '.treefile-context-menu', 
      callback: function(key, options) {
        posts_tree.click(key, options);
      },
      items: {
        "file_edit"      : { name: "Edit", icon: "fa-pencil" },
        //"file_rename"    : { name: "Rename", icon: "fa-i-cursor" },
        "file_delete"    : { name: "Delete", icon: "fa-trash" }
      }
    });
  },

  // build and style nodes
  build_nodes: function(in_elem, data, identifier = "") {
    jQuery.each(data, function(index, current_node){
      if(current_node.name == "") {
        var new_identifier = "";
      } else {
        var new_identifier = identifier + "/" + current_node.name;
      }
      var new_node = $('<li></li>');
      if(current_node.children) {
        // for folders

        if(current_node.children.length > 0)
          // full
          node_icon = "fa fa-folder";
        else
          // empty
          node_icon = "fa fa-folder-o";

        if(current_node.name == "") {
          node_name = "Posts";
        } else {
          node_name = current_node.name;
        }

        node_link = $('<a href="#'+ new_identifier +'" class="treefolder treefolder-context-menu"><i class="' + node_icon + '"></i><span>' + node_name + '</span></a>');

        // is closed or open?
        if($.inArray(new_identifier, sessionStorage.getItem(posts_tree.session_identifier).split(",")) >= 0) {
          new_list = $('<ul></ul>');
        } else {
          new_list = $('<ul class="hidden"></ul>');
        }

        // toggle no empty classes
        if(current_node.children.length > 0)
          node_link.click(function(event){
            posts_tree.toggle_node(event.currentTarget);
            event.preventDefault();
          });

        $(new_node).append(node_link);
        $(new_node).append(new_list);
        
        posts_tree.build_nodes(new_list, current_node.children, new_identifier);
      } else {
        // for files

        node_link = $('<a href="#'+ new_identifier +'" class="treefile treefile-context-menu"><i class="fa fa-file-o"></i><span>' + current_node.name + '</span></a>');
        node_link.click(function(event){
          posts_editor.edit(new_identifier);
          event.preventDefault();
        });

        $(new_node).append(node_link);

      }
      $(in_elem).append(new_node);
    });
    
  },

  toggle_node: function(node_link) {
    // do visible thing
    $(node_link).parent("li").children("ul").toggleClass("hidden");
    
    // get existing storage
    identifier = $(node_link).attr('href').replace("#", "");
    session_elements = sessionStorage.getItem(posts_tree.session_identifier).split(",");

    if($(node_link).parent("li").children("ul").hasClass("hidden")) {
      // is now hidden
      session_elements.splice( $.inArray(identifier, session_elements), 1 );
    } else {
      // is now visible
      session_elements.push(identifier)
    }

    // save new storage
    new_session_elements = $.unique(session_elements.sort()).join(","); 
    sessionStorage.setItem(posts_tree.session_identifier, new_session_elements);
  }

}