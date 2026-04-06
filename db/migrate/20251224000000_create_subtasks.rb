class CreateSubtasks < ActiveRecord::Migration[7.1]
  def change
    create_table :subtasks do |t|
      t.references :goal, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end
  end
end







