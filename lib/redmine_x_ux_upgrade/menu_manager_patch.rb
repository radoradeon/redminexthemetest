module RedmineXUxUpgrade
  module MenuControllerPatch
    module MenuController

      # *********************
      # * Redefined methods *
      # *********************

      # Redefined - line 60
      # Change - replaces original project menu, with our custom projectino menu
      def current_menu(project)
        if project && !project.new_record?
          :projectino_project_menu
        elsif self.class.main_menu
          :application_menu
        end
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        prepend MenuController
        def current_menu(project)
          self.current_menu(project)
        end
      end
    end
  end
  module MenuHelperPatch

    module MenuHelper

      # *********************
      # * Redefined methods *
      # *********************

      # Redefined - line 113
      # Change - in case of projectino menu, custom generator method is used
      def render_menu(menu, project=nil)
        menu_items = menu_items_for(menu, project)
        links = []

        if menu == :projectino_project_menu
          links = prepare_projectino_menu(menu_items, project)
        else
          menu_items.each do |node|
            links << render_menu_node(node, project)
          end
        end
        links.empty? ? nil : content_tag('ul', links.join.html_safe)
      end

      # Redefined - line 121
      # Change - some menu items are placed into new_entity submenu
      def render_menu_node(node, project=nil)
        if node.children.present? || !node.child_menus.nil?
          render_menu_node_with_children(node, project)
        else
          case
          when node.name == :settings && project
            render_projectino_project_settings(node, project)
          when node.name == :new_issue && node.parent.name == :new_entity
            render_new_entity_issue(node, project)
          when node.name == :new_timelog && node.parent.name == :new_entity
            render_new_entity_timelog(node, project)
          else
            caption, url, selected = extract_node_details(node, project)
            content_tag('li', render_single_menu_node(node, caption, url, selected))
          end
        end
      end

      # Redefined - line 174
      def render_single_menu_node(item, caption, url, selected)
        options = item.html_options(:selected => selected)
        options[:title] = caption
        # virtual nodes are only there for their children to be displayed in the menu
        # and should not do anything on click, except if otherwise defined elsewhere
        if url.blank?
          url = '#'
          options.reverse_merge!(:onclick => 'return false;')
        end
        link_to(h(caption), url, options)
      end

      # Redefined - line 208
      def extract_node_details(node, project=nil)
        item = node
        url =
            case item.url
            when Hash
              project.nil? ? item.url : {item.param => project}.merge(item.url)
            when Symbol
              if project
                send(item.url, project)
              else
                send(item.url)
              end
            else
              item.url
            end
        caption = item.caption(project)

        # fix for correct top menu highlighting
        if current_menu_item == :my
          selected = item.name == :my_page
        else
          selected = (current_menu_item == item.name)
        end

        return [caption, url, selected]
      end

      # ***************
      # * New methods *
      # ***************

      def render_projectino_project_settings(node, project)
        caption, url, selected = extract_node_details(node, project)
        return content_tag('li', render_single_menu_node(node, caption, url, selected), class: node.html_options[:class])
      end

      # new issue in new entity needs to hold project context, if user is in the project
      def render_new_entity_issue(node, project)
        caption, url, selected = @project ? extract_node_details(node, @project) : extract_node_details(node, project)
        return content_tag('li', render_single_menu_node(node, caption, url, selected))
      end

      # new timelog in new entity needs to hold project context, if user is in the project and it
      # also needs to hold task context, if user is in the project and in the specific task
      def render_new_entity_timelog(node, project)
        caption, url, selected = @project ? extract_node_details(node, @project) : extract_node_details(node, project)
        url = new_issue_time_entry_path(@issue) if @issue&.id
        return content_tag('li', render_single_menu_node(node, caption, url, selected))
      end

      def render_expanded_menu_node
        options = { :onclick => 'return false;',
                    :id=>"expanded-menu",
                    :class=>"far fa fa-chevron-down expanded-menu" }
        link_to('', '#', options)
      end

      def prepare_projectino_menu(menu_items, project)
        expanded_menu = menu_items.find { |node| node.name == :expanded_menu }
        settings_node = menu_items.find { |node| node.name == :settings }
        items_counter = 0
        links = []
        children = []

        menu_items.each do |node|
          next if node.name == :expanded_menu
          next if node.name == :settings

          if allowed_node?(node, User.current, project)
            if items_counter < RedmineXUxUpgradeSetting.number_of_items_in_project_menu
              items_counter += 1
              links << render_menu_node(node, project)
            else
              children << render_menu_node(node, project)
            end
          end
        end

        standard_children_list = "".html_safe.tap do |child_html|
          children.each do |child|
            child_html << child
          end
        end

        unless standard_children_list.empty?
          expanded_menu_html = render_expanded_menu_node.html_safe +
            content_tag(:div, standard_children_list, id: 'expanded-menu-items', class: 'menu-children')

          links << content_tag(:div, expanded_menu_html, class: 'expanded-menu-wrap')
        end
        links << render_menu_node(settings_node, project) if settings_node
        links
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        prepend MenuHelper
        def render_menu(menu, project=nil)
          self.render_menu(menu, project=nil)
        end
        def render_menu_node(node,project=nil)
          self.render_menu_node(node,project=nil)
        end
        def render_single_menu_node(item, caption, url, selected)
          self.render_single_menu_node(item, caption, url, selected)
        end
        def extract_node_details(node, project=nil)
          self.extract_node_details(node, project=nil)
        end
      end
    end
  end
  module MenuNodePatch
    module InstanceMethods

      # *********************
      # * Redefined methods *
      # *********************

      # Redefined - line 399
      # Replaces method originla remove!, which removes items only from first level -
      # however in UX Upgrade we have also submenus and the orginal method is not able to remove
      # items from these submenus (which is necessary in projectino extensions plugin)
      def remove!(child)
        if @children.include?(child)
          @children.delete(child)
          @last_items_count -= +1 if child && child.last
          child.parent = nil
          child
        else
          @children.each do |item|
            if item.children.include?(child)
              item.children.delete(child)
              child.parent = nil
            end
          end
        end
        child
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        prepend InstanceMethods
        def remove!(child)
          self.remove!(child)
        end
      end
    end
  end
end
unless Redmine::MenuManager::MenuController.included_modules.include?(RedmineXUxUpgrade::MenuControllerPatch)
  Redmine::MenuManager::MenuController.send(:include, RedmineXUxUpgrade::MenuControllerPatch)
end
unless Redmine::MenuManager::MenuHelper.included_modules.include?(RedmineXUxUpgrade::MenuHelperPatch)
  Redmine::MenuManager::MenuHelper.send(:include, RedmineXUxUpgrade::MenuHelperPatch)
end
unless Redmine::MenuManager::MenuNode.included_modules.include?(RedmineXUxUpgrade::MenuNodePatch)
  Redmine::MenuManager::MenuNode.send(:include, RedmineXUxUpgrade::MenuNodePatch)
end
