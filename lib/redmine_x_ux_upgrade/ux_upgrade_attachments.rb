module RedmineXUxUpgrade
  module UxUpgradeAttachments
    LOGO_NAME           = 'logo'
    LOGIN_NAME          = 'login'
    LOGIN_DESKTOP_NAME  = 'login_desktop'
    LOGIN_MOBILE_NAME   = 'login_mobile'
    LOGIN_DESKTOP_FILE  = 'login-2k.jpg'
    LOGIN_MOBILE_FILE   = 'login.jpg'


    # Saves files (logo + login images) on the ux upgrade settings page
    # @param {Object} params - params object (from settings controller plugin action)
    # @return {} - nothing is returned
    def self.save_settings_attachments(params)
      settings = Setting.find_by(name: 'plugin_000_redmine_x_ux_upgrade')

      if any_attachment?(params, LOGO_NAME)
        save_plugin_image(LOGO_NAME, params[LOGO_NAME.to_sym], settings)
      end
      if any_attachment?(params, LOGIN_DESKTOP_NAME)
        save_plugin_image(LOGIN_DESKTOP_NAME, params[LOGIN_DESKTOP_NAME.to_sym], settings)
      end
      if any_attachment?(params, LOGIN_MOBILE_NAME)
        save_plugin_image(LOGIN_MOBILE_NAME, params[LOGIN_MOBILE_NAME.to_sym], settings)
      end
    end

    # Delete files (logo or login images) on the ux upgrade settings page
    # @param {Object} params - params object (from settings controller plugin action)
    # @return {} - nothing is returned
    def self.delete_settings_attachments(params)
      return unless params[:name] && params[:format]

      settings = Setting.find(params[:format])
      if params[:name] == LOGO_NAME
        delete_logo(settings)
      elsif params[:name] == LOGIN_NAME
        delete_login(settings)
      end
    end

    private

    # Checks if params contain at least one attachment of given type (by name)
    # @param {Object} params - params object (from settings controller plugin action)
    # @param {String} name - type of the attachment (logo or login image)
    # @return {Boolean} - true if at least one attachment is present
    def self.any_attachment?(params, name)
      return false unless params[name.to_sym]

      attachment = params[name.to_sym]
      attachment.delete('dummy') if attachment['dummy']
      attachment.keys.any?
    end

    # Deltes Ux Upgrade logo image file and its record in the Attachments table
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {Boolean} - true if settings were updated succesfully
    def self.delete_logo(settings)
      delete_old_plugin_image(LOGO_NAME, settings)
      Attachment.where(container_id: settings.id, description: LOGO_NAME).delete_all
      settings.save
    end

    # Deltes Ux Upgrade login image files and their records in the Attachments table
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {Boolean} - true if settings were updated succesfully
    def self.delete_login(settings)
      delete_old_plugin_image(LOGIN_DESKTOP_NAME, settings)
      delete_old_plugin_image(LOGIN_MOBILE_NAME, settings)

      Attachment.where(container_id: settings.id, description: LOGIN_DESKTOP_NAME).delete_all
      Attachment.where(container_id: settings.id, description: LOGIN_MOBILE_NAME).delete_all

      settings.save
    end

    # Save ux upgrade plugin logo or login image (delete old image, save new image, copy it to the theme)
    # @param {String} name - type of the attachment (logo or login image)
    # @param {Object} attachment - attachment params object (from settings controller plugin action)
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {} - nothing is returned
    def self.save_plugin_image(name, attachment, settings)
      delete_old_plugin_image(name, settings) if name == LOGO_NAME
      save_attachment(name, attachment, settings)
      copy_new_plugin_image(name, settings)
    end

    # Saves Ux Upgrade logo or login image file as and attachment to the Attachments table
    # @param {String} name - type of the attachment (logo or login image)
    # @param {Object} attachment - attachment params object (from settings controller plugin action)
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {Boolean} - true if attachment (linked to the settings) was saved succesfully
    def self.save_attachment(name, attachment, settings)
      Attachment.where(container_id: settings.id, description: name).delete_all
      attachment[attachment.keys.first][:description] = name
      settings.save_attachments(attachment)
      Attachment.attach_files(settings, attachment)
      settings.save
    end

    # Copies new image file to the ux upgrade images folder
    # @param {String} name - type of the attachment (logo or login image)
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {} - nothing is returned
    def self.copy_new_plugin_image(name, settings)
      new_attachment = Attachment.where(container_id: settings.id, description: name).last
      if new_attachment
        path_to_attachment = File.join(Rails.root, 'files', new_attachment.disk_directory, new_attachment.disk_filename)
      end

      FileUtils.cp_r(path_to_attachment, image_path(name)) if path_to_attachment
    end

    # Deletes old image file in the ux upgrade images folder (or replaces it by the default one)
    # @param {String} name - type of the attachment (logo or login image)
    # @param {Object} settings - UX Upgrade plugin settings ActiveRecord object
    # @return {} - nothing is returned
    def self.delete_old_plugin_image(name, settings)
      old_attachment = Attachment.where(container_id: settings.id, description: name).last
      return unless old_attachment

      if name == LOGO_NAME
        path_to_logo = image_path(name, old_attachment.disk_filename)
        File.delete(path_to_logo) if path_to_logo && File.exist?(path_to_logo)
      else
        FileUtils.cp_r(default_image_path(name), image_path(name))
      end
    end

    # Builds path to corresponding file in rx theme images folder
    # @param {String} name - type of the attachment (logo or login image)
    # @param {String or nil} filename - name of the filename of the logo file
    # @return {String} - path to file corresponding to the given name
    def self.image_path(name, filename=nil)
      if name == LOGO_NAME && filename
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images', filename)
      elsif name == LOGO_NAME && filename.nil?
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images')
      elsif name == LOGIN_DESKTOP_NAME
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images', LOGIN_DESKTOP_FILE)
      elsif name == LOGIN_MOBILE_NAME
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images', LOGIN_MOBILE_FILE)
      end
    end

    # Builds path to corresponding default login image file in rx theme images/default_login folder
    # @param {String} name - type of the login attachment (login desktop or mobile image)
    # @return {String} - path to default image file corresponding to the given name
    def self.default_image_path(name)
      if name == LOGIN_DESKTOP_NAME
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images', 'default_login', LOGIN_DESKTOP_FILE)
      elsif name == LOGIN_MOBILE_NAME
        File.join(Rails.root, 'public', 'themes', 'redminex_theme', 'images', 'default_login', LOGIN_MOBILE_FILE)
      end
    end
  end
end