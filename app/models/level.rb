class Level
  include Mongoid::Document

  field :level_number, type: Integer
  field :level_name, type: String
  has_many :topics
end
