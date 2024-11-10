class TasksController < ApplicationController
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  # GET /tasks
  def index
    @tasks = Task.all
    render json: @tasks
  end


  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    if @task.save
      ActionCable.server.broadcast("tasks_channel", { task: @task })
      render json: @task, status: :created
      # redirect_to tasks_path, notice: "Task was successfully created."
    else
      render json: @task.errors, status: :unprocessable_entity
      # render :new
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, notice: "Task was successfully deleted."
  end

  private

  def task_params
    params.require(:task).permit(:content)
  end
end
