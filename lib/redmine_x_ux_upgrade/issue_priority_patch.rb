require_dependency 'issue_priority'
module RedmineXUxUpgrade
  module IssuePriorityPatch
    module InstanceMethods

      # *********************
      # * Redefined methods *
      # *********************

      # Redefined - line 45
      def css_classes
        position_name
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        prepend InstanceMethods
        def css_classes
          self.css_classes
        end

        # *********************
        # * Redefined methods *
        # *********************

        # Redefined - line 72
        def self.compute_position_names
          # do nothing
          false
        end
      end
    end
  end
end
unless IssuePriority.included_modules.include?(RedmineXUxUpgrade::IssuePriorityPatch)
  IssuePriority.send(:include, RedmineXUxUpgrade::IssuePriorityPatch)
end
