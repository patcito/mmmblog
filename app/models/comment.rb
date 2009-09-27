class Comment
  include MongoMapper::Document
  key :post_id, String, :null => false
  key :author, String, :null => false
  key :author_url, String, :null => false
  key :author_email, String, :null => false
  key :body, String, :null => false
  key :body_html, String, :null => false
  key :created_at, Time, :default => Time.now.utc
  key :updated_at, Time

  validates_presence_of :author, :body, :post

  belongs_to :post
  attr_accessor         :openid_error
  attr_accessor         :openid_valid
  def blank_openid_fields
    self.author_url = ""
    self.author_email = ""
  end

  def requires_openid_authentication?
    !!self.author.index(".")
  end
end