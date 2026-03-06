require "net/http"
require "json"
require "uri"

class RecommendationService
  API_URL = "https://api.groq.com/openai/v1/chat/completions"

  def self.rank_products(product_name, candidates)
    api_key = ENV["GROQ_RECOMMENDATION_API_KEY"]


    product_list = candidates.map(&:name).join("\n")

    prompt = <<~PROMPT
      A customer is viewing the product: "#{product_name}"

      From the following list of products, select the 3 most relevant recommendations.

      Products:
      #{product_list}

      Return ONLY the product names, one per line.
    PROMPT

    uri = URI(API_URL)

    body = {
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request.body = body.to_json

    response = http.request(request)

    json = JSON.parse(response.body)

    return [] unless json["choices"]

    content = json["choices"][0]["message"]["content"]

    content.split("\n").map do |line|
      line.gsub(/^\d+\.?\s*/, "").strip
    end
  rescue
    []
  end
end
