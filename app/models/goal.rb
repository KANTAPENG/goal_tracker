class Goal < ApplicationRecord
  belongs_to :user

  enum status: {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }

  validates :title, presence: true
  validates :deadline, presence: true
  validates :progress,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }
  before_validation :normalize_progress_and_status
  validate :deadline_must_be_in_future

  private

  def normalize_progress_and_status
    self.progress = 0 if progress.nil?

    # 當 status 為 completed 時，自動將 progress 設為 100
    if status == "completed"
      self.progress = 100
    end

    # 若 progress = 100，自動將狀態設為 completed
    if progress == 100
      self.status = "completed"
    end

    # 保證當 progress < 100 時，status 不會是 completed
    if progress < 100 && status == "completed"
      self.status = "in_progress"
    end
  end

  def deadline_must_be_in_future
    return unless deadline.present?

    if deadline < Date.today
      errors.add(:deadline, "必須是未來的日期")
    end
  end
end
