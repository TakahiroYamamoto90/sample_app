# 2024.06.14 gemini-ai対応 gemのrequireは基本不要
#require 'gemini-ai'

class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:show, :create, :destroy]
  before_action :correct_user,   only: :destroy

  # 2024.06.11 add modal dialog
  # micropost.showがルーターから呼ばれる
  def show
    @micropost = Micropost.find(params[:id])

=begin
    # 2024.06.14 implement generative ai
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY']
      },
      options: { model: 'gemini-pro', server_sent_events: true }
    )

    query = @micropost.content + " について要約して教えてください。"
    result = client.generate_content(
      { contents: { role: 'user', parts: { text: query } } }
    )
    @generative_text = result["candidates"][0]["content"]["parts"][0]["text"]
    # debugger
    respond_to do |format|
      format.html
      # link_toメソッドをremote: trueに設定したのでリクエストはjs形式で行われる
      format.js  # js形式で送信された場合はこちらが適応され、js.erbを探す
    end
=end
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # 2024.06.10 kaminari対応
      #@feed_items = current_user.feed.paginate(page: params[:page])
      # 2024.06.10 検索対応対応
      #@feed_items = current_user.feed.page(params[:page])
      @q = Micropost.none.ransack
      @feed_items = current_user.feed.page(params[:page]) 
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content,  :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end    
end
