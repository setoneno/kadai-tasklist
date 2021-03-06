class TasksController < ApplicationController
  before_action :require_user_logged_in
  before_action :correct_user, only: [:show, :edit, :update, :destroy]
  before_action :twitter_client, only: [:create]
 

  before_action :set_task, only: [:show, :edit, :update, :destroy]
   
  def index
    @tasks = current_user.tasks.page(params[:page]).per(10)
  end
  
  def show
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
       @client.update("#{@task.status}\r#{@task.content}\r")
      flash[:success] = 'Task が正常に投稿されました'
      redirect_to @task
    else
      @tasks = current_user.tasks.order('created_at DESC').page(params[:page])
      flash.now[:danger] = 'Task が投稿されませんでした'
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @task.update(task_params)
      flash[:success] = 'Task は正常に更新されました'
      redirect_to @task
    else
      flash.now[:danger] = 'Task は更新されませんでした'
      render :edit
    end
  end
  
  def destroy
     @task.destroy

     flash[:success] = 'Task は正常に削除されました'
     redirect_to @task
  end
  
  private
  
  def set_task
    @task = Task.find(params[:id])
  end

  # Strong Parameter
  def task_params
    params.require(:task).permit(:content, :status)
  end
  
  def correct_user
    @task = current_user.tasks.find_by(id: params[:id])
    unless @task
      redirect_to root_path
    end
  end
  
  def twitter_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_API_ID']
      config.consumer_secret = ENV['TWITTER_API_SECRET_ID']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN_ID']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET_ID']
    end
  end
end