class Microposts::QueryController < ApplicationController
  def index
    micropost =  Micropost.find(params[:id])
    #debugger
    #Base64.strict_encode64(open(micropost.image.variant) { |io| io.read })
    is_image_query = true? params[:is_image_query]

    if (is_image_query) 
      query_text = "この画像を説明してください"
      @answer = exec_image_query(micropost.image, query_text)
    else
      query_example_text = params[:query_example_text]
      query_text = micropost.content + " #{query_example_text}"
=begin
      # 2024.06.14 implement generative ai
      client = Gemini.new(
        credentials: {
          service: 'generative-language-api',
          api_key: ENV['GOOGLE_API_KEY']
        },
        options: { model: 'gemini-pro', server_sent_events: true }
      )

      result = client.generate_content(
        { contents: { role: 'user', parts: { text: query } } }
      )
      #@generative_text = result["candidates"][0]["content"]["parts"][0]["text"]
      @answer = result;
=end
      @answer = exec_text_query(query_text)
    end

    respond_to do |format|
      format.html
      format.json { render json: { answer: @answer } }
    end
  end

  def image
    micropost =  Micropost.find(params[:id])
    @answer = exec_image_query(micropost.image, "この画像を説明してください")

    respond_to do |format|
      format.html
      format.json { render json: { answer: @answer } }
    end

  end

end