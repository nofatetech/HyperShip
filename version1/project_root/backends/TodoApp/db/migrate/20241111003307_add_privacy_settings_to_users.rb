class AddPrivacySettingsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :privacy_level, :string
    add_column :users, :can_view_profile, :boolean
    add_column :users, :can_send_messages, :boolean
    add_column :users, :can_comment, :boolean
    add_column :users, :data_privacy_agreements, :json
  end
end
