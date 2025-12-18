class Goal < ApplicationRecord
  belongs_to :user

  enum status: {
    not_started: 0,
    in_progress: 1,
    completed: 2
  }

  validates :title, presence: true
  validates :deadline, presence: true
  validate :deadline_must_be_in_future

  private

  def deadline_must_be_in_future
    return unless deadline.present?

    if deadline < Date.today
      errors.add(:deadline, "必須是未來的日期")
    end
  end
end
