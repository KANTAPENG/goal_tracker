class GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  def index
    @goals = current_user.goals.order(created_at: :desc)
  end

  def show
  end

  def new
    @goal = current_user.goals.build
  end

  def edit
  end

  def create
    @goal = current_user.goals.build(goal_params)

    if @goal.save
      redirect_to @goal, notice: '目標已成功創建。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
      redirect_to @goal, notice: '目標已成功更新。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to goals_path, notice: '目標已成功刪除。'
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :deadline, :status, :progress)
  end
end
