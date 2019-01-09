class Song
  include Mongoid::Document
  belongs_to :artist

  field :title, type: String
  field :genre, type: String
end
