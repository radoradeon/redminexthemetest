class RedmineXUxUpgradeSetting
  def self.show_contacts_in_new_entity_menu?
    settings[:show_contacts_in_new_entity_menu].to_i > 0
  end

  def self.show_documents_in_new_entity_menu?
    settings[:show_documents_in_new_entity_menu].to_i > 0
  end

  def self.show_news_in_new_entity_menu?
    settings[:show_news_in_new_entity_menu].to_i > 0
  end

  def self.show_spent_time_in_top_menu?
    settings[:show_spent_time_in_top_menu]
  end

  def self.number_of_items_in_project_menu
    if settings[:number_of_items_in_project_menu].to_i < 1
      8
    else
      settings[:number_of_items_in_project_menu].to_i
    end
  end

  def self.remember_collapsed_issues_state?
    settings[:remember_collapsed_issues_state]
  end

  private

  def self.settings
    RedmineXUxUpgrade.settings
  end
end
