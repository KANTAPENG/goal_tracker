class SubtasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_subtask, only: [:update, :destroy]

  def create
    @subtask = @goal.subtasks.new(subtask_params)

    if @subtask.save
      redirect_to @goal, notice: "已新增子目標"
    else
      redirect_to @goal, alert: @subtask.errors.full_messages.to_sentence
    end
  end

  def update
    if @subtask.update(subtask_params)
      # Subtask model 也會在 completed 變動時自動回算進度；這裡再保險呼叫一次
      @goal.recalculate_progress_with_lock!
      redirect_to @goal
    else
      redirect_to @goal, alert: @subtask.errors.full_messages.to_sentence
    end
  end

  def destroy
    @subtask.destroy
    redirect_to @goal, notice: "已刪除子目標"
  end

  def reorder
    # 只處理當前使用者擁有的子目標，避免越權
    ids = Array(params[:order])

    Subtask
      .joins(:goal)
      .where(id: ids, goals: { user_id: current_user.id })
      .find_each do |subtask|
        new_index = ids.index(subtask.id.to_s)
        next unless new_index

        subtask.update_columns(position: new_index + 1)
      end

    head :ok
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:goal_id])
  end

  def set_subtask
    @subtask = @goal.subtasks.find(params[:id])
  end

  def subtask_params
    params.require(:subtask).permit(:title, :completed)
  end
end
