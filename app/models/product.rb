class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  validates :name, :price, presence: true
  validates :stock,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }


  LOW_STOCK_THRESHOLD = 5

  def in_stock?
    stock > 0
  end

  def out_of_stock?
    stock.zero?
  end

  def low_stock?
    stock <= LOW_STOCK_THRESHOLD
  end

  def reduce_stock!(quantity)
    raise StandardError, "Invalid quantity" if quantity <= 0

    with_lock do
      raise StandardError, "Insufficient stock" if stock < quantity
      update!(stock: stock - quantity)
    end
  end

  def restore_stock!(quantity)
    raise StandardError, "Invalid quantity" if quantity <= 0

    with_lock do
      update!(stock: stock + quantity)
    end
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :name,        type: :text
      indexes :description, type: :text
      indexes :price,       type: :float
    end
  end

  def as_indexed_json(options = {})
    as_json(
      only: [ :name, :description, :price ]
    )
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: [ "name^3", "description" ],
            fuzziness: "AUTO"
          }
        }
      }
    )
  end
end
