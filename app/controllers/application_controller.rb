class ApplicationController < ActionController::Base
  include SessionsHelper
  include QueryHelper # 2024.06.15 Queryヘルパを追加
  
  private
  
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end  

    def microposts_search_params
      params.require(:q).permit(:content_cont)
    end    
end
