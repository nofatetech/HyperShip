class CreateBlacklistedTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :jti, null: false
      t.text :received_token, null: false # Store the full token for logs and security reasons

      t.timestamps
    end
    add_index :blacklisted_tokens, :jti
  end
end
