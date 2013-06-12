class TopicsController < ApplicationController
  before_filter :load_topic, :only => [:edit, :update, :take_test] 

  def index
    @topics = Topic.all
  end

  def show
    @topic = Topic.find(params[:id])
  end
  
  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:message] = 'Successfully created'
      redirect_to topic_url(@topic)
    else
      render :action => :new
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    if @topic.update_attributes(params[:topic])
      flash[:message] = 'Successfully updated'
      redirect_to topic_url(@topic)
    else
      render :action => :update
    end
  end

  def destroy

  end

  def take_test
    @questions = @topic.questions

  end

  def attempt_question
    @question = Question.find_by(:id => params[:id])
    attempt = Attempt.where(:user => current_user, :question => @question).first
    attempt = Attempt.create(:user => current_user, :question => @question) if attempt.nil? 
    question_params = params[:question]
    if question_params["option"]["is_valid"] == true && attempt.count == 0
      attempt.update_attribute(solved: true, cookies: @question.cookies)
    elsif question_params["option"]["is_valid"] == true && attempt.count > 0
      cookies = (@question.cookies / attempt.count).round
      attempt.update_attributes(solved: true, cookies: cookies)
    else
      attempt.update_attributes(count: attempt.count + 1)
    end
    render :nothing => true
  end

  private
  def load_topic
    @topic = Topic.find_by(:id => params[:id])
  end


end
