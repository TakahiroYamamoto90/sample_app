require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  #test "should get root" do
  #  get root_url
  #  assert_response :success
  #end

  # 14章でのテストで追加
  def setup
    @user = users(:michael)
  end

  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Ruby on Rails Tutorial Sample App"
    # フォロー機能で追加
    log_in_as(@user)
    get root_path
    assert_response :success
    assert_select "a[href=?]", following_user_path(@user) #ログインしないと情報が取れない
    assert_select "a[href=?]", followers_user_path(@user) #ログインしないと情報が取れない
    assert_match @user.following.count.to_s, response.body
    assert_match @user.followers.count.to_s, response.body
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end  
end