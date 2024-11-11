class AddReferralAndMarketingToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :referral_code, :string
    add_column :users, :utm_parameters, :json
  end
end
