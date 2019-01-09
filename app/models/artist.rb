class Artist
  include Mongoid::Document
  has_many :songs

  field :name, type: String
  field :years_active, type: String
  field :origin, type: String
end
