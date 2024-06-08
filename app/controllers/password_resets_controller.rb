class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:password].empty?                  # （3）への対応
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)                     # （4）への対応
      #log_outの場合はcurrent_userが取得できずにエラーが発生
      #log_out #セッションを盗まれたことに気づいたユーザーが即座にパスワードをリセットするため
      # 以下二個の実装はちょっと迷った
      forget @user # パスワードを変更したのでremember_tokenを破棄する
      reset_session # session_tokenを破棄する
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity      # （2）への対応
    end
  end

  private

  # パラメータからパスワードのみを受け取るように絞る
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # beforeフィルタ  

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end    
end