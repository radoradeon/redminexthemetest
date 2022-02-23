module RedmineXUxUpgrade
  def self.settings() Setting[:plugin_000_redmine_x_ux_upgrade].blank? ? {} : Setting[:plugin_000_redmine_x_ux_upgrade]  end

  def self.logo_url
    logo = Setting.find_by(name: 'plugin_000_redmine_x_ux_upgrade')&.attachments.where(description: 'logo')&.last
    redmine_x_ux_theme_path = File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images')
    path_to_logo = "#{redmine_x_ux_theme_path}/#{logo.disk_filename}" if logo

    if path_to_logo && File.exist?(path_to_logo)
      return ActionController::Base.helpers.asset_path("#{Redmine::Utils::relative_url_root}/themes/redminex_theme/images/#{logo.disk_filename}", :plugin => '000_redmine_x_ux_upgrade')
    end
    #default logo if not set
    ActionController::Base.helpers.asset_path("#{Redmine::Utils::relative_url_root}/themes/redminex_theme/images/logo.svg", :plugin => '000_redmine_x_ux_upgrade')
  end

  # list of supported plugins (aka styles that are not being loaded) that go to %w[]: redmine_agile redmine_banner redmine_checklists redmine_contacts redmine_contacts_invoices redmine_contacts_helpdesk redmine_crm redmine_dashboard redmine_dmsf redmine_issue_dynamic_edit redmine_issue_evm redmine_issue_templates redmine_mentions redmine_messenger redmine_resources redmine_risks that_meeting
  def self.supported_plugin_list
    %w[].freeze
  end

  # list of forbidden redmine css files that go to %w[]:application context_menu context_menu_rtl jquery/jquery-ui-1.11.0 jstoolbar responsive rtl scm tribute-3.7.3
  def self.redmine_css_to_overwrite
    %w[].freeze
  end
end
