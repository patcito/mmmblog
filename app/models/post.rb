class Post
  include MongoMapper::Document
  include MongoMapperExt::Filter

  ensure_index :slug
  ensure_index :tags
  key :_id, String
  key :title, String, :null => false
  key :author, String, :null => false
  key :slug, String, :null => false
  key :body, String, :null => false
  key :body_html, String, :null => false
  key :active, Boolean, :default => true, :null => false
  key :approved_comments_count, Integer, :default => 0, :null => false
  key :cached_tag_list, String
  key :published_at, Time
  key :edited_at, Time
  key :tags, Array, :default => []
  DEFAULT_LIMIT = 15
  has_many :comments
  before_validation_on_create :check_slug
  timestamps!

  def sluggize
    if self.slug.blank?
      self.slug = self.title.gsub(/[^A-Za-z0-9\s\-]/, "")[0,40].strip.gsub(/\s+/, "-").downcase
    end
  end

  def check_slug
    self.sluggize
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
