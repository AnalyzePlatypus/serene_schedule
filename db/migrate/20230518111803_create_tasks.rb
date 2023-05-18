class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :notes
      t.float :estimated_hours
      t.float :actual_hours
      t.integer :priority

      t.timestamps
    end
  end
end
