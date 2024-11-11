class AddSocialInteractionsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :followers_count, :integer
    add_column :users, :following_count, :integer
    add_column :users, :comments_count, :integer
  end
end
