Redmine::Plugin.register '000_redmine_x_ux_upgrade'.to_sym do
  name 'RedmineX UX Upgrade'
  author 'Ondřej Svejkovský'
  description 'RedmineX UX Upgrade'
  version '1.2.3' # for Redmine v4.2.3
  url 'www.redmine-x.com'

  settings(
    :default => {
      :show_spent_time_in_top_menu => false,
      :number_of_items_in_project_menu => 8,
      :remember_collapsed_issues_state => false
    },
    :partial => 'settings/redmine_x_ux_upgrade_settings'
  )
end

include RedmineXUxUpgrade::MenuHelper
register_menu_items

require_dependency 'redmine_x_ux_upgrade/view_projects_hook'
require 'redmine_x_ux_upgrade'
require 'redmine_x_ux_upgrade/enumeration_patch'
require 'redmine_x_ux_upgrade/menu_manager_patch'
require 'redmine_x_ux_upgrade/plugin_patch'
require 'redmine_x_ux_upgrade/issue_priority_patch'
require 'redmine_x_ux_upgrade/enumerations_controller_patch'
require 'redmine_x_ux_upgrade/settings_controller_patch'
require 'redmine_x_ux_upgrade/setting_patch'
require 'redmine_x_ux_upgrade/attachment_patch'
require 'redmine_x_ux_upgrade/application_helper_patch'
require 'redmine_x_ux_upgrade/issues_helper_patch'
require 'redmine_x_ux_upgrade/my_page_patch'
require 'redmine_x_ux_upgrade/my_helper_patch'
require 'redmine_x_ux_upgrade/attachments_helper_patch'
require 'redmine_x_ux_upgrade/queries_helper_patch'

# Copy projectino theme and to public folder
redmine_x_ux_upgrade_path = File.join(Rails.root, 'plugins', '000_redmine_x_ux_upgrade')
FileUtils.cp_r("#{redmine_x_ux_upgrade_path}/assets/themes", "#{Rails.root}/public")

# Set redmine theme to 'projectino'
if ActiveRecord::Base.connection.table_exists? 'settings'
  Setting.ui_theme = 'redminex_theme'
  # Write settings to db, when plugin is installed for the 1st time => required by change logo functionality
  if Setting.where(name: 'plugin_000_redmine_x_ux_upgrade').empty?
    Setting["plugin_000_redmine_x_ux_upgrade"] = {
      show_spent_time_in_top_menu: false,
      number_of_items_in_project_menu: 8,
      remember_collapsed_issues_state: false
    }
  end
end

RedmineApp::Application.routes.prepend do
  scope '/home' do
    resources :welcome
  end
  match '/', :to => 'my#page', :via => [:get]
  post '/settings/plugin/000_redmine_x_ux_upgrade/remove_logo', to: 'settings#delete_attachment', as: 'delete_attachment'
end

