module RedmineXUxUpgrade
    module QueriesHelperPatch
      def self.included(receiver)
        receiver.send(:include, InstanceMethods)
      end
      module InstanceMethods

        # ***************
        # * New methods *
        # ***************

        # grouped_query_results method for projectino, which passes not only group name, but also whole
        # group object and group column. This is used in the issue index view template, where id of the
        # group object and group column name is used for identification of the group (for save purposes)
        def grouped_query_results_projectino(items, query, &block)
          result_count_by_group = query.result_count_by_group
          previous_group, first = false, true
          totals_by_group = query.totalable_columns.inject({}) do |h, column|
            h[column] = query.total_by_group_for(column)
            h
          end
          items.each do |item|
            group = group_name = group_count = nil
            if query.grouped?
              # This is the group object, which we want to pass to the block calling this method as well
              group = query.group_by_column.group_value(item)
              if first || group != previous_group
                if group.blank? && group != false
                  group_name = "(#{l(:label_blank_value)})"
                else
                  group_name = format_object(group)
                end
                group_name ||= ""
                group_count = result_count_by_group ? result_count_by_group[group] : nil
                group_totals = totals_by_group.map {|column, t| total_tag(column, t[group] || 0)}.join(" ").html_safe
              end
            end
            # Here we pass the group object and column name to the block
            yield item, group_name, group_count, group_totals, query.group_by, group
            previous_group, first = group, false
          end
        end
      end
    end
  end
  unless QueriesHelper.included_modules.include?(RedmineXUxUpgrade::QueriesHelperPatch)
    QueriesHelper.send(:include, RedmineXUxUpgrade::QueriesHelperPatch)
  end