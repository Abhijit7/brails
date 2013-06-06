require 'spec_helper'

describe LevelsController do
  before do
@level = create(:level)
  end

  context "GET index action for logged in user" do
    before do
      @user = create(:user)
      sign_in :user, @user
    end

    it 'Should display the levels' do
      get :index
      assigns(:levels).should_not be_nil
    end

    it 'Should show number of cookies for each level' do
      level = create(:level)
      4.times {create(:topic, :level => level)}
      cookies = 0
      level.topics.each {|topic| cookies = cookies + topic.cookies}
      level_cookies = {level.id => cookies}
      get :index
      assigns(:level_cookies).should eq(level_cookies)
    end
  end

  context "Show as a action for logged in user" do
    before do
      @user = create(:user)
      sign_in :user, @user
    end

    it 'Should show list of topics of the level' do
      4.times {create(:topic, :level => @level)}
      get :show, :id => @level.id
      assigns(:topics).should be_present
      assigns(:topics).each {|topic| topic.level.id.should eq(@level.id)}
    end

    it 'Should mark topic as completed' do
      level = create(:level)
      5.times {create(:topic, :level => level)}
      level.topics.each {|topic| 4.times {create(:question, :topic => topic)}}
      level.topics[0].questions.each {|question| create(:attempt, :solved => true, :question => question, :user => @user)}
      get :show, :id => level.id
      assigns(:topics).each do |topic|
        topic.questions.each {|question| question.attempt.solved.should be_true}
      end
    end

    it 'Should mark the topic as incomplete' do
      flag = true
      level = create(:level)
      5.times {create(:topic, :level => level)}
      level.topics.each {|topic| 4.times {create(:question, :topic => topic)}}
      level.topics[0].questions.each {|question| create(:attempt, :solved => (flag = !flag), :question => question, :user => @user)}
      get :show, :id => level.id
      assigns(:topics)[0].questions[0].attempt.should eq(level.topics[0].questions[0].attempt)
    end
  end

  context 'Only admin can create level' do
    before do
      @user = create(:admin)
      sign_in :user, @user
    end

    it "assigns a new level as @level" do
        get :new
        assigns(:level).new_record?.should be_true
    end

    it 'should create new level' do
      level = build(:level).attributes
      level.delete("_id")
      post :create, {:level => level}
      level = assigns(:level)
      level.persisted?.should be_true
    end
  end

  context "Only admin can edit or update level" do
    before(:each) do
      @user = create(:admin)
      sign_in :user, @user
    end 
  
    it 'should edit as an action' do
      get :edit, {:id => @level.id}
      level = assigns(:level)
      level.should_not be_nil
    end

    it 'should update' do
      level = @level.attributes
      level.level_number = 10
      put :update, {:level => level, :id => @level.id}
      level1 = assigns(:level)
      level1.level_number.should eq(10)
    end
  end

  context "Only admin can destroy level" do
    before(:each) do
      @user = create(:admin)
      sign_in :user, @user
    end 

    it 'Should delete' do
      delete :destroy, id: @level.id
      assigns(:level).should be_nil
    end
  end

  context "When all topics of level are completed" do
    before do
      @user = create(:student)
      sign_in :user, @user
    end   

    it 'Should un-lock the bonus round' do
      level = create(:level)
      5.times { create(:user_topic, :is_completed => true, :topic => create(:topic, :level => level))}
      create(:bonus_round, :level => level)
      create(:bonus_cookie, :bonus_round => level.bonus_round)
      get :unLock_bonusRound, :id => level.id
      assigns(:level).bonus_round.bonus_cookie.is_locked.should be_false
    end
  end

  context "When any of the topic is not completed" do
    before do
      @user = create(:student)
      sign_in :user, @user
    end

    it 'Should not un-lock the bonus round' do
      flag = true
      level = create(:level)
      5.times {create(:user_topic, :is_completed => (flag = !flag), :topic => create(:topic, :level => level))}
      create(:bonus_round, :level => level)
      create(:bonus_cookie, :bonus_round => level.bonus_round)
      get :unLock_bonusRound, :id => level.id
      assigns(:level).bonus_round.bonus_cookie.is_locked.should be_true
    end
  end

end
