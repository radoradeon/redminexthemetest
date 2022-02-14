require_dependency 'setting'
module RedmineXUxUpgrade
  module SettingPatch
    module InstanceMethods

      # ***************
      # * New methods *
      # ***************

      # Enables to use logo image from the settings
      def get_logo
        logo = Setting.find_by(name: "plugin_000_redmine_x_ux_upgrade").attachments.last
        render :partial => 'common/image', :locals => {:path => download_named_attachment_path(logo, logo.filename), :alt => logo.filename}
      end
    end

    def self.included(receiver)
      receiver.class_eval do
        prepend InstanceMethods
        acts_as_attachable
        def self.get_logo_url
          self.get_logo
        end
      end
    end
  end
end
unless Setting.included_modules.include?(RedmineXUxUpgrade::SettingPatch)
  Setting.send(:include, RedmineXUxUpgrade::SettingPatch)
end
