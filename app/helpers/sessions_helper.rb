module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    user.remember
    # cookieの「user_id」属性にuser.idを書き込む
    cookies.permanent.encrypted[:user_id] = user.id
    # cookieの「remember_token」属性にuserのremember_token属性(仮想属性=DB上は持たない)を書き込む
    cookies.permanent[:remember_token] = user.remember_token
  end  

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    #if session[:user_id]
    #  @current_user ||= User.find_by(id: session[:user_id])
    #end
    # WEBリクエスト処理内でセッションcookieが存在する場合
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    # WEBリクエスト処理内でセッションが存在しない場合で、永続cookieが存在する場合
    elsif (user_id = cookies.encrypted[:user_id])
      #raise       # テストがパスすれば、この部分がテストされていないことがわかる
      user = User.find_by(id: user_id)
      # 永続cookie上の:remember_tokenの値を取得して、DB上のremember_digestを復号化したもの=remember_tokenと一致するか確認する
      # 対象digest切り替え方式に変更
      #if user && user.authenticated?(cookies[:remember_token])
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end  

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget # インスタンスメソッドforgetを呼び出す
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end  

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    # railsのプリセットメソッド：全てのsession cookieを削除
    reset_session
    @current_user = nil   # 安全のため
  end

  # アクセスしようとしたURLを保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end  
end
