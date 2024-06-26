class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, 
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    #@users = User.paginate(page: params[:page])
    # 2024.06.10 kaminari対応    
    #@users = User.where(activated: true).paginate(page: params[:page])
    #@users = User.where(activated: true).page(params[:page])
    # 2024.06.10 検索対応
    @q = User.ransack(params[:q]) # 検索オブジェクト作成
    @users = @q.result.where(activated: true).page(params[:page])
    
  end  

  def show
    @user = User.find(params[:id])
    # 2024.06.10 kaminari対応
    #@microposts = @user.microposts.paginate(page: params[:page])
    #@microposts = @user.microposts.page(params[:page])
    # 2024.06.10 検索対応
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = @user.microposts.ransack(microposts_search_params) # 検索オブジェクト作成
      @microposts = @q.result.page(params[:page])
    else
      @q = Micropost.none.ransack
      @microposts = @user.microposts.page(params[:page])
    end
    @url = user_path(@user)
    redirect_to root_url and return unless @user.activated?
    #debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # 06.04一旦コメントアウト
      #reset_session
      #log_in @user      
      #flash[:success] = "Welcome to the Sample App!"
      #redirect_to @user
      ##redirect_to user_url(@user)
      # 06.05 リファクタリング
      #UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end 

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    # 2024.06.10 kaminari対応
    #@users = @user.following.paginate(page: params[:page])
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    # 2024.06.10 kaminari対応
    #@users = @user.followers.paginate(page: params[:page])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end  

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,
                                   :follow_notification)#, :admin)
    end

    # 親のapplication_controllerに移動
    ## ログイン済みユーザーかどうか確認
    #def logged_in_user
    #  unless logged_in?
    #    store_location
    #    flash[:danger] = "Please log in."
    #    redirect_to login_url, status: :see_other
    #  end
    #end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end    
end
