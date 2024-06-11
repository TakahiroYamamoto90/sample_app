require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'ul.pagination', count: 1
    # 2024.06.10 kaminari対応
    #@user.microposts.paginate(page: 1).each do |micropost|
    @user.microposts.page(1).each do |micropost|
      assert_match micropost.content, response.body
    end
    # フォロー機能で追加
    assert_select "a[href=?]", following_user_path(@user)
    assert_select "a[href=?]", followers_user_path(@user)
    assert_match @user.following.count.to_s, response.body
    assert_match @user.followers.count.to_s, response.body
  end

  test "profile micropost search" do
    # Micropost Search
    get user_path(@user), params: {q: {content_cont: "orange"}}
    q = @user.microposts.ransack(content_cont: "orange")
    q.result.page(1).each do |micropost|
      assert_match micropost.content, response.body
    end    
  end  

=begin
  test "home micropost feed search" do
    # Micropost Search
    get root_path, params: {q: {content_cont: "フランス"}}
    q = @user.feed.ransack(content_cont: "フランス")
    q.result.page(1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
=end
end
