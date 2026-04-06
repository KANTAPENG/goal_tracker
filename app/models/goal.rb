class Goal < ApplicationRecord
  belongs_to :user
  has_many :subtasks, dependent: :destroy

  enum status: {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }

  validates :title, presence: true
  validates :deadline, presence: true
  validate :deadline_must_be_in_future

  def progress_percentage
    calculated_progress, = calculate_progress

    calculated_progress
  end

  # 由子任務變動時呼叫，用來重新計算並儲存目標進度
  def recalculate_progress_with_lock!
    with_lock do
      calculated_progress, completed_count, total_count = calculate_progress

      attributes_to_update = { progress: calculated_progress }

      if total_count.positive? && completed_count == total_count
        attributes_to_update[:status] = :completed
      end

      update!(attributes_to_update)
    end
  end

  private

  # 回傳 [progress_percentage(Integer), completed_count(Integer), total_count(Integer)]
  def calculate_progress
    total = subtasks.count
    return [0, 0, 0] unless total.positive?

    completed_count = subtasks.where(completed: true).count
    progress_value = ((completed_count.to_f / total) * 100).round

    [progress_value, completed_count, total]
  end

  def deadline_must_be_in_future
    return unless deadline.present?

    if deadline < Date.today
      errors.add(:deadline, "必須是未來的日期")
    end
  end
end

