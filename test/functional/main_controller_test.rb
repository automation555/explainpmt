require File.dirname(__FILE__) + '/../test_helper'
require 'main_controller'

# Re-raise errors caught by the controller.
class MainController; def rescue_action(e) raise e end; end

class MainControllerTest < Test::Unit::TestCase
  fixtures :users, :projects, :projects_users, :story_cards, :milestones
  
  def setup
    @controller = MainController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @admin      = User.find 1
    @user       = User.find 2
    @project_1  = Project.find 1
    @project_2  = Project.find 2
    @story_card_a = StoryCard.find 1
    @story_card_b = StoryCard.find 2
    @story_card_c = StoryCard.find 3
    @story_card_d = StoryCard.find 4
    @p1_milestone_today = Milestone.find 1
    @p1_milestone_in_30 = Milestone.find 2
    @p2_milestone_today = Milestone.find 5
    @p2_milestone_in_30 = Milestone.find 6
  end
  
  def test_dashboard_for_user
    my_projects = [ @project_1, @project_2 ].sort { |a,b| a.name <=> b.name }
    my_story_cards = [ @story_card_b, @story_card_c ]
    milestones = [ @p1_milestone_today, @p2_milestone_today,
      @p1_milestone_in_30, @p2_milestone_in_30 ]
    @request.session[ :current_user_id ] = @user.id
    get :dashboard
    assert_response :success
    assert_template 'dashboard'
    assert_equal @user, assigns( :current_user )
    assert_equal my_projects, assigns( :my_projects )
    assert_equal my_story_cards, assigns( :my_story_cards )
    assert_equal milestones.size, assigns( :upcoming_milestones ).size
    milestones.each { |m| assert assigns( :upcoming_milestones ).include?( m ) }
    assert_tag :tag => 'a', :content => @user.name,
      :attributes => { :href => "users/show/#{@user.id}" },
      :ancestor => { :attributes => { :id => 'CurrentUserInfo' } }
    my_projects.each do |p|
      assert_tag :tag => 'a', :content => p.name,
        :attributes => { :href => "project/#{p.id}" },
        :ancestor => { :attributes => { :id => 'MyProjects' } }
    end
  end
  
  def test_dashboard_for_admin
    my_projects = [ @project_1 ]
    my_story_cards = [ @story_card_a ]
    milestones = [ @p1_milestone_today, @p1_milestone_in_30 ]
    @request.session[ :current_user_id ] = @admin.id
    get :dashboard
    assert_response :success
    assert_template 'dashboard'
    assert_equal @admin, assigns( :current_user )
    assert_equal my_projects, assigns( :my_projects )
    assert_equal my_story_cards, assigns( :my_story_cards )
    assert_equal milestones.size, assigns( :upcoming_milestones ).size
    milestones.each { |m| assert assigns( :upcoming_milestones ).include?( m ) }
    assert_tag :tag => 'a', :content => @admin.name,
      :attributes => { :href => "users/show/#{@admin.id}" },
      :ancestor => { :attributes => { :id => 'CurrentUserInfo' } }
    my_projects.each do |p|
      assert_tag :tag => 'a', :content => p.name,
        :attributes => { :href => "project/#{p.id}" },
        :ancestor => { :attributes => { :id => 'MyProjects' } }
    end
  end

  def test_dashboard_for_not_logged_in
    get :dashboard
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
    assert_equal "Please log in, and we'll send you right along.",
                                                      flash[ :status ]  
  end
end
