# Defines methods used by view_project_hook
module RedmineXUxUpgrade
  module ProjectAggregatorHelper

    # Calculates project completion value in percent
    #
    # @param hook_caller [Object] object contained in context[:hook_caller], which is
    #   passed to hooks as a parameter (= object which calls the hook)
    # @return [Integer] project completion value in percent
    def project_completion(hook_caller)
      # total_estimated_hours and total_hours are instance variables of project controller,
      # from where our view_projects_show_right hook is called
      unless hook_caller.assigns['total_estimated_hours'] &&
            hook_caller.assigns['total_estimated_hours'] > 0 &&
            hook_caller.assigns['total_hours']
        return 0
      end

      (hook_caller.assigns['total_hours'] / hook_caller.assigns['total_estimated_hours'] * 100).round.to_i
    end

    # Calculates progress of the project = average of done rations of all issues including
    # subprojects, closed issues are counted as 100%.
    #
    # @param hook_caller [Object] object contained in context[:hook_caller], which is
    #   passed to hooks as a parameter (= object which calls the hook)
    # @return [Integer] project done ratio
    def project_progress(hook_caller)
      project = hook_caller.assigns['project']
      return 0 unless project 

      issues = Issue.arel_table

      cond = project.project_condition(true)
      total_issues_count = Issue.visible.where(cond).count
      result = Issue.visible.open.where(cond).pluck(issues[:done_ratio].sum, issues[:id].count)
      closed_issues_progress = (total_issues_count - result[0][1]) * 100
      return 0 unless result[0][0]
      ((result[0][0] + closed_issues_progress.to_f) / total_issues_count.to_f).round
    end
  end

end
