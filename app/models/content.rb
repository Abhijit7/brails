class Content
  include Mongoid::Document
  field :title, type: String
  field :content_body, type: String
  field :sq_no, type: Integer

end

