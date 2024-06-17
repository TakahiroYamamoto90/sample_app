module QueryHelper

  # 文字列trueをboolにキャストする
  def true?(obj)
    obj.to_s.downcase == "true"
  end

  def exec_text_query(query_text)
    # 2024.06.14 implement generative ai
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY']
      },
      options: { model: 'gemini-pro', server_sent_events: true }
    )
    
    # return result content
    #result = client.generate_content(
    #  { contents: { role: 'user', parts: { text: query } } }
    #)
    client.generate_content(
      { contents: { role: 'user', parts: { text: query_text } } }
    )    
  end

  def exec_image_query(target_image, query_text)
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY']
      },
      options: { model: 'gemini-pro-vision', server_sent_events: true }
    )

    result = client.stream_generate_content(
      { contents: [
        { role: 'user', parts: [
          { text: query_text },
          { inline_data: {
            mime_type: 'image/jpeg',
            data: Base64.strict_encode64(File.read('piano.jpg'))
          } }
        ] }
      ] }
    )
  end

end