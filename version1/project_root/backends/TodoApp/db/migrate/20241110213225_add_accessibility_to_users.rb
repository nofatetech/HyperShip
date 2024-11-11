class AddAccessibilityToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :font_size, :string
    add_column :users, :color_scheme, :string
    add_column :users, :language_preference, :string
    add_column :users, :screen_reader_enabled, :boolean
  end
end
