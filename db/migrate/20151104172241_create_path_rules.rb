class CreatePathRules < ActiveRecord::Migration
  def change
    create_table :path_rules do |t|
      t.references :guide
      t.references :path
      t.integer :position

      t.timestamps
    end
  end
end
