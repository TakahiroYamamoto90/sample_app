require "test_helper"

#class UsersIndexTest < ActionDispatch::IntegrationTest
class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

=begin
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
=end
end

class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin

  test "should render the index page" do
    assert_template 'users/index'
  end

  test "should paginate users" do
    assert_select 'ul.pagination'
  end

  test "should have delete links" do
    # 2024.06.10 kaminari対応
    #first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users = User.where(activated: true).page(1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test "should be able to delete non-admin user" do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "should display only activated users" do
    # ページにいる最初のユーザーを無効化する。
    # 無効なユーザーを作成するだけでは、
    # Railsで最初のページに表示される保証がないので不十分
    # 2024.06.10 kaminari対応
    #User.paginate(page: 1).first.toggle!(:activated)
    User.page(1).first.toggle!(:activated)
    # /usersを再度取得して、無効化済みのユーザーが表示されていないことを確かめる
    get users_path      
    # 表示されているすべてのユーザーが有効化済みであることを確かめる
    assigns(:users).each do |user|
      assert user.activated?
    end
  end

  test "admin user search should hit active user" do
    get users_path
    q = User.ransack(name_cont: "Michael Example")
    q.result.page(1).each do |user|
      assert_match user.name, response.body
    end    
  end

  test "admin user search should not hit active user" do
    get users_path
    q = User.ransack(name_cont: "Inactive User")
    q.result.page(1).each do |user|
      assert_no_match user.name, response.body
    end    
  end    
end

class UsersNonAdminIndexTest < UsersIndex

  test "should not have delete links as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "non-admin user search" do
    log_in_as(@non_admin)
    get users_path
    q = User.ransack(name_cont: "Michael Example")
    q.result.page(1).each do |user|
      assert_match user.name, response.body
    end    
  end

  test "non-admin user search should not hit active user" do
    log_in_as(@non_admin)
    get users_path
    q = User.ransack(name_cont: "Inactive User")
    q.result.page(1).each do |user|
      assert_no_match user.name, response.body
    end    
  end    
end
