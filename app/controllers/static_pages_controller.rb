class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      # 2024.06.10 kaminari対応
      #feed_items = current_user.feed.paginate(page: params[:page])
      @feed_items = current_user.feed.page(params[:page])
    end
  end

  def help
  end

  def about
  end  

  def contact
  end  
end
