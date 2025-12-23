class AddProgressToGoals < ActiveRecord::Migration[7.1]
  def change
    add_column :goals, :progress, :integer, default: 0, null: false
  end
end


