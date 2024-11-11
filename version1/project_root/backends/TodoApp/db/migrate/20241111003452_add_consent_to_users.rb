class AddConsentToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :consent_given_at, :datetime
    # add_column :users, :data_privacy_agreements, :json
  end
end
