class AddTwoFactorAuthenticationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :two_factor_enabled, :boolean
    add_column :users, :two_factor_method, :string
  end
end
