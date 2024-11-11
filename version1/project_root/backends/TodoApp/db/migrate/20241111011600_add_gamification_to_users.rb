class AddGamificationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :points, :integer
    add_column :users, :level, :integer
    add_column :users, :rank, :string
    add_column :users, :achievements, :json
    add_column :users, :activity_count, :integer
    add_column :users, :favorite_tags, :json
  end
end
