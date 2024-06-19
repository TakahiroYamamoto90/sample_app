class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      # 2024.06.10 kaminari対応
      #feed_items = current_user.feed.paginate(page: params[:page])
      # 2024.06.10 検索対応
      #@feed_items = current_user.feed.page(params[:page])
      if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
        @q = current_user.feed.ransack(microposts_search_params)
        @feed_items = @q.result.page(params[:page])
      else
        @q = Micropost.none.ransack
        @feed_items = current_user.feed.page(params[:page])
      end      
    end
  end

  def help
  end

  def about
  end  

  def contact
  end  
end
