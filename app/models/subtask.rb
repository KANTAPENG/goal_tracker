class Subtask < ApplicationRecord
  belongs_to :goal

  # 依 position 由小到大排序
  default_scope { order(:position) }

  validates :title, presence: true

  before_validation :set_default_position, on: :create

  # 子任務完成狀態變動或被刪除時，重新計算所屬目標的進度
  after_save :recalculate_goal_progress, if: :saved_change_to_completed?
  after_destroy :recalculate_goal_progress

  # 將當前子任務往上移一個位置（只影響同一個 goal 底下的子任務）
  def move_higher!
    return if position.to_i <= 1

    goal.with_lock do
      higher_subtask = goal.subtasks
                           .where("position < ?", position)
                           .order(position: :desc)
                           .limit(1)
                           .first

      return unless higher_subtask

      swap_positions!(higher_subtask)
    end
  end

  # 將當前子任務往下移一個位置（只影響同一個 goal 底下的子任務）
  def move_lower!
    goal.with_lock do
      lower_subtask = goal.subtasks
                          .where("position > ?", position)
                          .order(position: :asc)
                          .limit(1)
                          .first

      return unless lower_subtask

      swap_positions!(lower_subtask)
    end
  end

  private

  # 新建立的子任務自動排在該 goal 最後一個 position 之後
  def set_default_position
    return if position.present? || goal.blank?

    goal.with_lock do
      max_position = goal.subtasks.maximum(:position)
      self.position = max_position.to_i + 1
    end
  end

  # 只在同一個 goal 範圍內交換兩個子任務的 position
  def swap_positions!(other_subtask)
    Subtask.transaction do
      current_position = position
      other_position = other_subtask.position

      # 使用 update_columns 避免觸發不必要的 callback，但仍在同一個 transaction 內
      update_columns(position: other_position)
      other_subtask.update_columns(position: current_position)
    end
  end

  def recalculate_goal_progress
    goal.recalculate_progress_with_lock!
  end
end

