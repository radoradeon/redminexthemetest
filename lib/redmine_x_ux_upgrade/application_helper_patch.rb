module RedmineXUxUpgrade
  module ApplicationHelperPatch
    def self.included(receiver)
      receiver.send(:include, InstanceMethods)
      receiver.class_eval do
        alias_method :body_css_classes_without_projectino, :body_css_classes
        alias_method :body_css_classes, :body_css_classes_with_projectino

        # *********************
        # * Redefined methods *
        # *********************

        # Redefined - line 553
        def render_project_jump_box
          projects = projects_for_jump_box(User.current)
          if @project && @project.persisted?
            text = @project.name_was
          end
          text ||= l(:label_jump_to_a_project)
          url = autocomplete_projects_path(:format => 'js', :jump => current_menu_item)
          trigger = content_tag('span', text, :class => 'drdn-trigger')
          q = text_field_tag('q', '', :id => 'projects-quick-search',
                             :class => 'autocomplete',
                             :data => {:automcomplete_url => url},
                             :autocomplete => 'off')
          # CHANGE - 'projects_path(:jump => current_menu_item)' in 'all' is replaced by 'projects_path'
          #   with the jump parameter, link to all projects in the jump box leads to all issues, if user
          #   is on all issues page before entering the jump box - this is caused by adding all issues
          #   menu item to the top menu (it is not in the original redmine)
          all = link_to(l(:label_project_all), projects_path,
                        :class => (@project.nil? && controller.class.main_menu ? 'selected' : nil))
          content =
            content_tag('div',
                        content_tag('div', q, :class => 'quick-search') +
                          content_tag('div', render_projects_for_jump_box(projects, selected: @project),
                                      :class => 'drdn-items projects selection') +
                          content_tag('div', all, :class => 'drdn-items all-projects selection'),
                        :class => 'drdn-content')
          content_tag('div', trigger + content, :id => "project-jump", :class => "drdn")

        end

        # Redefined - line 1638
        def stylesheet_link_tag(*sources)
            projectino_supported_plugins = RedmineXUxUpgrade.supported_plugin_list
            redmine_css_list = RedmineXUxUpgrade.redmine_css_to_overwrite
            options = sources.last.is_a?(Hash) ? sources.pop : {}
            plugin = options.delete(:plugin)
            sources = sources.map do |source|
              if plugin && !projectino_supported_plugins.include?(plugin)
                "#{Redmine::Utils::relative_url_root}/plugin_assets/#{plugin}/stylesheets/#{source}"
              elsif current_theme && current_theme.stylesheets.include?(source)
                current_theme.stylesheet_path(source)
              elsif !redmine_css_list.include?(source) && !projectino_supported_plugins.include?(plugin)
                source
              else
                # needs to return css file, otherwise throws routing error
                "#{Redmine::Utils::relative_url_root}/plugin_assets/000_redmine_x_ux_upgrade/stylesheets/blank"
              end
            end
            super *sources, options
        end

        # Redefined - line 1723
        def favicon
          favicon_path = "#{Redmine::Utils::relative_url_root}/themes/redminex_theme/images/favicon"

          "<link rel='apple-touch-icon' sizes='180x180' href='#{favicon_path}/apple-touch-icon.png'>
           <link rel='icon' type='image/png' sizes='32x32' href='#{favicon_path}/favicon-32x32.png'>
           <link rel='icon' type='image/png' sizes='16x16' href='#{favicon_path}/favicon-16x16.png'>
           <link rel='manifest' href='#{favicon_path}/site.webmanifest'>
           <link rel='mask-icon' href='#{favicon_path}/safari-pinned-tab.svg' color='#5bbad5'>
           <link rel='shortcut icon' href='#{favicon_path}/favicon.ico'> <meta name='msapplication-TileColor' content='#ffffff'>
           <meta name='theme-color' content='#ffffff'>".html_safe
        end

        # ***************
        # * New methods *
        # ***************

        # Displays a link to user's account page if active with custom text
        #
        # @param [User] user - instance of User class to create link for
        # @param [Hash] options - params in hash. Custom text should be included in these options
        # @return [String] - html link string or name, if not authorized or if User doesn't exist
        def link_to_user_with_text(user, options={})
          if user.is_a?(User)
            text = h(options[:text])
            if user.active? || (User.current.admin? && user.logged?)
              only_path = options[:only_path].nil? ? true : options[:only_path]
              link_to text, user_url(user, :only_path => only_path), :class => user.css_classes
            else
              text
            end
          else
            h(user.to_s)
          end
        end

        # UX Upgrade uses context menu with edit button, which enables to edit issue directly
        def link_to_context_menu_with_edit(issue)
          edit_button = link_to(l(:button_edit), edit_issue_path(issue), title: l(:button_edit), class: 'icon-only icon-edit')
          edit_button + link_to_context_menu
        end
      end
    end
    module InstanceMethods

      # ********************
      # * Extended methods *
      # ********************

      # Extended - line 798
      def body_css_classes_with_projectino
        css = body_css_classes_without_projectino
        css += ' rx-upgrade'
      end
    end
  end
end
unless ApplicationHelper.included_modules.include?(RedmineXUxUpgrade::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineXUxUpgrade::ApplicationHelperPatch)
end
