require "test_helper"

class Following < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user  = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
end

class FollowPagesTest < Following

  test "following page" do
    get following_user_path(@user)
    assert_response :success
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_response :success
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end

class FollowTest < Following

  test "should follow a user the standard way" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
    assert_redirected_to @other
  end

  test "should follow a user with Hotwire" do
    assert_difference "@user.following.count", 1 do
      post relationships_path(format: :turbo_stream),
           params: { followed_id: @other.id }
    end
  end

  test "should send follow notification email" do
    post relationships_path, params: {followed_id: @other.id}
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "should not send follow notification email" do
    not_notify = users(:michael)
    post relationships_path, params: {followed_id: not_notify.id}
    assert_equal 0, ActionMailer::Base.deliveries.size
  end  
end

class Unfollow < Following

  def setup
    super
    @user.follow(@other)
    @relationship = @user.active_relationships.find_by(followed_id: @other.id)
  end
end

class UnfollowTest < Unfollow

  test "should unfollow a user the standard way" do
    assert_difference "@user.following.count", -1 do
      delete relationship_path(@relationship)
    end
    assert_response :see_other
    assert_redirected_to @other
  end

  test "should unfollow a user with Hotwire" do
    assert_difference "@user.following.count", -1 do
      delete relationship_path(@relationship, format: :turbo_stream)
    end
  end

  test "feed on Home page" do
    get root_path
    # 2024.06.10 kaminari対応
    #@user.feed.paginate(page: 1).each do |micropost|
    @user.feed.page(1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.user.name), response.body
    end
  end

  # @relationshipは@user=michaelが@other=archerをフォローしたもの
  # archerのfollow_notification: trueの場合はメールが送信される
  test "should send unfollow notification email" do
    #@other.follow_notification = true # 強制的に通知フラグをON
    #assert_equal true, @other.follow_notification
    delete relationship_path(@relationship)
    # setupでのfollowで1通、deleteで1通
    assert_equal 2, ActionMailer::Base.deliveries.size # follow email and unfollow email
  end

  test "should not send unfollow notification email" do
    not_notify = users(:malory3)
    assert_equal false, not_notify.follow_notification
    @user.follow(not_notify)
    relationship = @user.active_relationships.find_by(followed_id: not_notify.id)
    delete relationship_path(relationship)
     # setupでのfollowで1通、unfollowの通知は送信されない
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

end