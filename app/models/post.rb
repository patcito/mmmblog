class Post
  include MongoMapper::Document
  key :title, String, :null => false
  key :author, String, :null => false
  key :slug, String, :null => false
  key :body, String, :null => false
  key :body_html, String, :null => false
  key :active, Boolean, :default => true, :null => false
  key :approved_comments_count, Integer, :default => 0, :null => false
  key :cached_tag_list, String
  key :published_at, Time
  key :created_at, Time, :default => Time.now
  key :updated_at, Time
  key :edited_at, Time
  key :tags, Array, :default => []
  DEFAULT_LIMIT = 15
  has_many :comments
  validate :check_slug
  before_save :update_edited_at

  def update_edited_at
    self.edited_at = Time.now unless edited_at
  end

  def set_slug
    self.slug = self.title if slug.blank?
    result = slug.downcase
    result.gsub!(/&(\d)+;/, '')  # Ditch Entities
    result.gsub!('&', 'and')     # Replace & with 'and'
    result.gsub!(/['"]/, '')    # replace quotes by nothing
    result.gsub!(/\W/, ' ')     # strip all non word chars
    result.gsub!(/\ +/, '-')    # replace all white space sections with a dash
    result.gsub!(/(-)$/, '')    # trim dashes
    result.gsub!(/^(-)/, '')    # trim dashes
    result.gsub!(/[^a-zA-Z0-9\-]/, '-') # Get rid of anything we don't like
    self.slug = result
  end

  def check_slug
    self.set_slug
    if Post.find_by_slug(self.slug)
      self.errors.add('slug', 'Slug already taken')
    end
  end

  def tags=(t)
    if t.kind_of?(String)
      t = t.downcase.split(",").join(" ").split(" ")
    end
    t = t.collect do |tag|
      tag.gsub("#", "sharp").gsub(".", "dot").gsub("www", "w3")
    end
    self[:tags] = t
  end

  def self.tag_cloud(conditions = {})
    @tag_cloud_code ||= RAILS_ROOT + "/app/javascripts/tag_cloud.js"
    self.database.eval(File.read(@tag_cloud_code), conditions)
  end

  def self.all_tags(conditions = {})
    @all_tags ||= RAILS_ROOT + "/app/javascripts/all_tags.js"
    self.database.eval(File.read(@all_tags), conditions)
  end

  def self.find_latest(options = {})
    tag = options.delete(:tag)
    author = options.delete(:author)
    options = {
      :order      => 'published_at desc',
      :conditions => (author)? {:published_at => { :$lt => Time.now},  :author => author.capitalize} :  {:published_at => { :$lt => Time.now}},
      :limit      => DEFAULT_LIMIT
    }.merge!(options)
    if tag
      options[:conditions].merge!({:tags => tag.to_a})
    end
    find(:all, options)
  end
end