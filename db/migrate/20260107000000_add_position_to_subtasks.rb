class AddPositionToSubtasks < ActiveRecord::Migration[7.1]
  def up
    add_column :subtasks, :position, :integer

    # 依照每個 goal 的 created_at 順序，為既有資料補上連續的 position
    say_with_time "Backfilling subtasks.position" do
      goal_ids = select_values("SELECT DISTINCT goal_id FROM subtasks")

      goal_ids.each do |goal_id|
        rows = select_all(<<~SQL.squish)
          SELECT id
          FROM subtasks
          WHERE goal_id = #{goal_id.to_i}
          ORDER BY created_at ASC, id ASC
        SQL

        rows.each_with_index do |row, index|
          execute <<~SQL.squish
            UPDATE subtasks
            SET position = #{index + 1}
            WHERE id = #{row["id"].to_i}
          SQL
        end
      end
    end

    change_column_null :subtasks, :position, false
    add_index :subtasks, [:goal_id, :position], unique: true
  end

  def down
    remove_index :subtasks, column: [:goal_id, :position]
    remove_column :subtasks, :position
  end
end






