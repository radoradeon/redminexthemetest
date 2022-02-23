module RedmineXUxUpgrade
  module MenuHelper
    # Registers all UX Upgrade menu items for all new menus
    # @return [nil] - nothing is returned
    def register_menu_items
      return if @registered
      @registered = true

      top_menu_hamburger_additional_features
      top_menu_hamburger_plugins
      top_menu_hamburger_system
      projectino_top_menu
      new_entity_menu
      projectino_project_menu
    end

    private

    # Registers menu items for "top_menu_hamburger_additional_features" menu
    # @return [nil] - nothing is returned
    def top_menu_hamburger_additional_features
      Redmine::MenuManager.map :top_menu_hamburger_additional_features do |menu|
        menu.push :users, {:controller => 'users'}, :caption => :label_user_plural,
                  :html => {:class => 'icon icon-user'}, :if => Proc.new { User.current.admin? }
      end
    end

    # Registers menu items for "top_menu_hamburger_plugins" menu
    # @return [nil] - nothing is returned
    def top_menu_hamburger_plugins
      Redmine::MenuManager.map :top_menu_hamburger_plugins do |menu|
      end
    end

    # Registers menu items for "top_menu_hamburger_system" menu
    # @return [nil] - nothing is returned
    def top_menu_hamburger_system
      Redmine::MenuManager.map :top_menu_hamburger_system do |menu|
        menu.push :administration, { :controller => 'admin', :action => 'index' }, :if => Proc.new { User.current.admin? }
        menu.push :logout, :signout_path, :html => {:method => 'post'}, :if => Proc.new { User.current.logged? }, :last => true
      end
    end

    # Registers menu items for "projectino_top_menu" menu
    # @return [nil] - nothing is returned
    def projectino_top_menu
      Redmine::MenuManager.map :projectino_top_menu do |menu|
        menu.push :my_page, { :controller => 'my', :action => 'page' }, :if => Proc.new { User.current.logged? }
        menu.push :projects, { :controller => 'projects', :action => 'index' }, :caption => :label_project_plural
        menu.push :issues, { :controller => 'issues', :action => 'index' }, :caption => :label_issue_plural
        menu.push :time_entries, { :controller => 'timelog', :action => 'index' }, :caption => :label_spent_time, :if => Proc.new{ RedmineXUxUpgradeSetting.show_spent_time_in_top_menu? }
      end
    end

    # Registers menu items for "new_entity_menu" menu
    # @return [nil] - nothing is returned
    def new_entity_menu
      Redmine::MenuManager.map :new_entity_menu do |menu|
        menu.push :new_entity, nil, :caption => ' New ',
                  :html => { :id => 'new-entity' }
        menu.push :new_issue,
                  { :controller => 'issues', :action => 'new', :copy_from => nil },
                  :param => :project_id, :caption => :label_issue_new,
                  :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                  :permission => :add_issues,
                  :parent => :new_entity
        menu.push :new_timelog, { :controller => 'timelog', :action => 'new' }, :param => :project_id,:permission => :log_time, :caption => :button_log_time, :parent => :new_entity
        menu.push :new_project, { :controller => 'projects', :action => 'new' },:permission => :add_project, :caption => :label_project_new, :parent => :new_entity, :if => Proc.new { User.current.allowed_to?(:add_project, nil, :global => true) }
        menu.push :new_user, {:controller => 'users', :action => 'new'}, :caption => :label_user_new, :parent => :new_entity, :if => Proc.new { User.current.admin? }
      end
    end

    # Registers menu items for "projectino_project_menu" menu
    # @return [nil] - nothing is returned
    def projectino_project_menu
      Redmine::MenuManager.map :projectino_project_menu do |menu|
        menu.push :new_object, nil, :caption => ' + ',
                  :if => Proc.new { |p| Setting.new_item_menu_tab == '2' },
                  :html => { :id => 'new-object', :onclick => 'uxu.menu.toggleNewObjectDropdown(); return false;' }
        menu.push :new_issue_sub,
                  { :controller => 'issues', :action => 'new', :copy_from => nil },
                  :param => :project_id, :caption => :label_issue_new,
                  :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                  :if => Proc.new { |p| Issue.allowed_target_trackers(p).any? },
                  :permission => :add_issues,
                  :parent => :new_object
        menu.push :new_issue_category, {:controller => 'issue_categories', :action => 'new'},
                  :param => :project_id, :caption => :label_issue_category_new,
                  :parent => :new_object
        menu.push :new_version, {:controller => 'versions', :action => 'new'}, :param => :project_id, :caption => :label_version_new,
                  :parent => :new_object
        menu.push :new_timelog, {:controller => 'timelog', :action => 'new'}, :param => :project_id, :caption => :button_log_time,
                  :parent => :new_object
        menu.push :new_news, {:controller => 'news', :action => 'new'}, :param => :project_id, :caption => :label_news_new,
                  :parent => :new_object
        menu.push :new_document, {:controller => 'documents', :action => 'new'}, :param => :project_id, :caption => :label_document_new,
                  :parent => :new_object
        menu.push :new_wiki_page, {:controller => 'wiki', :action => 'new'}, :param => :project_id, :caption => :label_wiki_page_new,
                  :parent => :new_object
        menu.push :new_file, {:controller => 'files', :action => 'new'}, :param => :project_id, :caption => :label_attachment_new,
                  :parent => :new_object

        menu.push :overview, { :controller => 'projects', :action => 'show' }
        menu.push :activity, { :controller => 'activities', :action => 'index' }
        menu.push :roadmap, { :controller => 'versions', :action => 'index' }, :param => :project_id
        menu.push :issues, { :controller => 'issues', :action => 'index' }, :param => :project_id, :caption => :label_issue_plural
        menu.push :new_issue, { :controller => 'issues', :action => 'new', :copy_from => nil }, :param => :project_id, :caption => :label_issue_new,
                  :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                  :if => Proc.new { |p| Setting.new_item_menu_tab == '1' && Issue.allowed_target_trackers(p).any? },
                  :permission => :add_issues
        menu.push :time_entries, { :controller => 'timelog', :action => 'index' }, :param => :project_id, :caption => :label_spent_time
        menu.push :gantt, { :controller => 'gantts', :action => 'show' }, :param => :project_id, :caption => :label_gantt
        menu.push :calendar, { :controller => 'calendars', :action => 'show' }, :param => :project_id, :caption => :label_calendar
        menu.push :news, { :controller => 'news', :action => 'index' }, :param => :project_id, :caption => :label_news_plural
        menu.push :documents, { :controller => 'documents', :action => 'index' }, :param => :project_id, :caption => :label_document_plural
        menu.push :wiki, { :controller => 'wiki', :action => 'show', :id => nil }, :param => :project_id,
                  :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
        menu.push :boards, { :controller => 'boards', :action => 'index', :id => nil }, :param => :project_id,
                  :if => Proc.new { |p| p.boards.any? }, :caption => :label_board_plural
        menu.push :files, { :controller => 'files', :action => 'index' }, :caption => :label_file_plural, :param => :project_id
        menu.push :repository, { :controller => 'repositories', :action => 'show', :repository_id => nil, :path => nil, :rev => nil },
                  :if => Proc.new { |p| p.repository && !p.repository.new_record? }
        menu.push :settings, { :controller => 'projects', :action => 'settings' }, :last => true
      end
    end
  end
end
