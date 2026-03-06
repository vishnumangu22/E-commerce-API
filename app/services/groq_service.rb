require "net/http"
require "uri"
require "json"

class GroqService
  API_URL = "https://api.groq.com/openai/v1/chat/completions"

  PROMPTS = [
    "Write a catchy ecommerce product description for %s under 40 words.",
    "Create a professional product description highlighting the benefits of %s in under 40 words.",
    "Describe the main features and advantages of %s for an online store in under 40 words.",
    "Write a short marketing style description for %s that attracts buyers. Limit to 40 words.",
    "Generate a concise ecommerce product description for %s focusing on usability and value."
  ]

  def self.generate_description(product_name)
    api_key = ENV["GROQ_DESCRIPTION_API_KEY"]

    prompt = format(PROMPTS.sample, product_name)

    uri = URI(API_URL)

    body = {
      model: "llama-3.1-8b-instant",
      temperature: 0.9,
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
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    response = http.request(request)

    json = JSON.parse(response.body)

    if json["choices"]
      description = json["choices"][0]["message"]["content"]
      description.gsub('"', "") # remove quotes if present
    else
      "AI description unavailable"
    end
  end
end
