module RedmineXUxUpgrade
  module IssuesHelperPatch
    def self.included(receiver)
      receiver.send(:include, InstanceMethods)
      receiver.class_eval do

        # *********************
        # * Redefined methods *
        # *********************

        # Redefined - line 92
        # Change - buttons now contain edit button
        def render_descendants_tree(issue)
          manage_relations = User.current.allowed_to?(:manage_subtasks, issue.project)
          s = +'<table class="list issues odd-even">'
          issue_list(
            issue.descendants.visible.
              preload(:status, :priority, :tracker,
                      :assigned_to).sort_by(&:lft)) do |child, level|
            css = +"issue issue-#{child.id} hascontextmenu #{child.css_classes}"
            css << " idnt idnt-#{level}" if level > 0
            buttons   =
              if manage_relations
                link_to(
                  l(:label_delete_link_to_subtask),
                  issue_path(
                    {:id => child.id, :issue => {:parent_issue_id => ''},
                     :back_url => issue_path(issue.id), :no_flash => '1'}
                  ),
                  :method => :put,
                  :data => {:confirm => l(:text_are_you_sure)},
                  :title => l(:label_delete_link_to_subtask),
                  :class => 'icon-only icon-link-break'
                )
              else
                "".html_safe
              end
            # Change - this method from application helper patch adds edit button to the buttons html
            buttons << link_to_context_menu_with_edit(issue)
            s <<
              content_tag(
                'tr',
                content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil),
                            :class => 'checkbox') +
                   content_tag('td',
                               link_to_issue(
                                 child,
                                 :project => (issue.project_id != child.project_id)),
                               :class => 'subject') +
                   content_tag('td', h(child.status), :class => 'status') +
                   content_tag('td', link_to_user(child.assigned_to), :class => 'assigned_to') +
                   content_tag('td', format_date(child.start_date), :class => 'start_date') +
                   content_tag('td', format_date(child.due_date), :class => 'due_date') +
                   content_tag('td',
                               (if child.disabled_core_fields.include?('done_ratio')
                                  ''
                                else
                                  progress_bar(child.done_ratio)
                                end),
                               :class=> 'done_ratio') +
                   content_tag('td', buttons, :class => 'buttons'),
                :class => css)
          end
          s << '</table>'
          s.html_safe
        end
      end
    end    
    module InstanceMethods

      # ***************
      # * New methods *
      # ***************

      # group_issue_list method for projectino, which passes not only group name, but also whole
      # group object and group column. This is used in the issue index view template, where id of the
      # group object and group column name is used for identification of the group (for save purposes)
      def grouped_issue_list_projectino(issues, query, &block)
        ancestors = []
        # Here we use grouped_query_results_projectino method defined in the queries helper patch, which includes
        # also group_object and group_column
        grouped_query_results_projectino(issues, query) do |issue, group_name, group_count, group_totals, group_column, group_object|
          while ancestors.any? &&
                !issue.is_descendant_of?(ancestors.last)
            ancestors.pop
          end

          # Prepare group object id, which will be used for identification of the grouped issue blocks
          name = format_object(group_object, false)
          name = name.empty? ? 'blank' : name.gsub(/\s+/, '_')
          id = ''
          if group_object
            id = "-#{group_object.id}" if group_object.respond_to?(:id)
          else
            id = '-nil'
          end

          group_object_id = "issue-group-#{group_column}-#{name}#{id}"

          # We pass group_object_id further to the block calling this method
          yield issue, ancestors.size, group_name, group_count, group_totals, group_object_id
          ancestors << issue unless issue.leaf?
        end
      end
    end
  end
end
unless IssuesHelper.included_modules.include?(RedmineXUxUpgrade::IssuesHelperPatch)
  IssuesHelper.send(:include, RedmineXUxUpgrade::IssuesHelperPatch)
end
