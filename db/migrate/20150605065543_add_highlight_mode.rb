class AddHighlightMode < ActiveRecord::Migration
  def change
    add_column :languages, :highlight_mode, :string, null: true
  end
end
