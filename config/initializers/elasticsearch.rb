Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: "https://localhost:9200",
  user: "elastic",
  password: "cD4sEL+PaGEmBA-1dzNk",
  transport_options: {
    ssl: { verify: false }
  }
)
