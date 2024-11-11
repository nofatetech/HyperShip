class AddPreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :theme, :string
    add_column :users, :locale, :string
    add_column :users, :notification_preferences, :json
    add_column :users, :layout_preferences, :json
  end
end
