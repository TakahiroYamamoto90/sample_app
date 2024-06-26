require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "should paginate microposts" do
    get root_path
    assert_select 'ul.pagination'
  end

  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    #assert_select 'a[href=?]', '/?page=1'  # 正しいページネーションリンク
    #assert_select 'a[href=?]', "/users/#{ @user.id }?page=2"  # 正しいページネーションリンク
    # 2024.06.10 kaminari対応 HTMLタグの構成が変わったためテストを変更
    assert_select 'a.page-link', html: '2'
  end

  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "should have micropost delete links on own profile page" do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    # 2024.06.10 kaminari対応
    #first_micropost = @user.microposts.paginate(page: 1).first
    first_micropost = @user.microposts.page(1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MicropostSidebarTest < MicropostsInterface

  test "should display the right micropost count" do
    get root_path
    assert_match "#{ @user.microposts.count } micropost", response.body
  end

  test "should user proper pluralization for zero microposts" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 micropost", response.body
  end

  test "should user proper pluralization for one micropost" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end

class ImageUploadTest < MicropostsInterface

  test "should have a file input field for images" do
    get root_path
    assert_select 'input[type=file]'
  end

  test "should be able to attach an image" do
    cont = "This micropost really ties the room together."
    img  = fixture_file_upload('kitten.jpg', 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    assert assigns(:micropost).image.attached?
  end
end