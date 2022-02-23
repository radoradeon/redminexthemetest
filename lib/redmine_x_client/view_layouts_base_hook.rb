module RedmineXClient
  class ViewLayoutsBaseHook < Redmine::Hook::ViewListener
    # Adds SmartsUpp chat js to the base layout (i.e. to every page)
    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag('client.css', plugin: :redmine_x_client) +
      javascript_include_tag('client.js', plugin: :redmine_x_client)
    end
  end
end
