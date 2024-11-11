class AddActivityLogsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :last_login_at, :datetime
    add_column :users, :ip_address, :string
    add_column :users, :browser_info, :string
    add_column :users, :login_history, :json
  end
end
