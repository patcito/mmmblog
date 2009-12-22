# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def post_slug_path(post,tag=nil,author=nil,opts={})
    tag ||= params[:tag]
    author ||= params[:author]
    if params[:tag] && params[:author]
      slug_with_author_tag_path({:slug=>post.slug,:author=>post.author.to_s,:tag=>params[:tag],:year=>post.created_at.year,:day=>post.created_at.day,:month=>post.created_at.month}.merge(opts))
    elsif params[:tag]
      slug_with_tag_path({:slug=>post.slug,:tag=>params[:tag],:year=>post.created_at.year,:day=>post.created_at.day,:month=>post.created_at.month}.merge(opts))
    elsif params[:author]
      slug_with_author_path({:slug=>post.slug,:author=>post.author.to_s,:year=>post.created_at.year,:day=>post.created_at.day,:month=>post.created_at.month}.merge(opts))
    else
      slug_path({:slug=>post.slug,:year=>post.created_at.year,:day=>post.created_at.day,:month=>post.created_at.month}.merge(opts))
    end
  end

  def comment_form_url(post, comment)
    return post_author_slug_comments_path if params[:author]
    post_slug_comments_path
  end

  def custom_posts(tag=nil,author=nil, opts={})
    tag ||= params[:tag]
    author ||= params[:author]
    if tag && author
      posts_with_author_tag_path({:author=>author,:tag=>tag}.merge(opts))
    elsif tag
      posts_with_tag_path({:tag=>tag}.merge(opts))
    elsif author
      posts_with_author_path({:author=>author}.merge(opts))
    else
      posts_path
    end
  end

  def custom_atom_posts(tag=nil,author=nil)
    tag ||= params[:tag]
    author ||= params[:author]
    if tag && author
      posts_with_author_tag_url(:author=>author,:tag=>tag, :format => 'atom')
    elsif tag
      posts_with_tag_url(:tag=>tag, :format => 'atom')
    elsif author
      posts_with_author_url(:author=>author, :format => 'atom')
    else
      posts_url(:format => 'atom')
    end
  end

  def custom_atom_comments(tag=nil, author=nil, post=nil)
    tag ||= params[:tag]
    author ||= params[:author]
    if post
      if tag && author
        slug_comments_with_author_tag_url(:author=>author,:tag=>tag, :format => 'atom')
      elsif tag
        slug_comments_with_tag_url(:tag=>tag, :format => 'atom')
      elsif author
        slug_comments_with_author_url(:author=>author, :format => 'atom')
      else
        slug_comments_url(:format => 'atom')
      end
    else
      if tag && author
        all_comments_with_author_tag_url(:author=>author,:tag=>tag, :format => 'atom')
      elsif tag
        all_comments_with_tag_url(:tag=>tag, :format => 'atom')
      elsif author
        all_comments_with_author_url(:author=>author, :format => 'atom')
      else
        all_comments_url(:format => 'atom')
      end
    end
  end

  def posts_title(post=nil, tag=nil, author=nil)
    title = ''
    title << "#{post.title} - " if post
    if author && tag
      title << "#{fullname(author)} on #{tag} - "
    elsif author
      title << "#{fullname(author)} - "
    end
    title << AppConfig.title
  end

  def fullname(author)
    author+' '+AppConfig.author["writers"][author.to_s.downcase]
  end

  def linked_tag_list(tags)
    tags.collect {|tag| link_to(h(tag), custom_posts(tag, params[:author]))}.join(", ")
  end

  def tag_cloud(tags = [], options = {})
    if params[:author]
      tags = Post.tag_cloud({:author=>params[:author]})
    else
      tags = Post.tag_cloud()
    end
    return "" if tags.size == 0
    max_size = options.delete(:max_size) || 35
    min_size = options.delete(:min_size) || 12

    tag_class = options.delete(:tag_class) || "tag"

    lowest_value, highest_value = tags.minmax_by { |tag| tag["count"].to_i }

    spread = (highest_value["count"] - lowest_value["count"])
    spread = 1 if spread == 0
    ratio = (max_size - min_size) / spread

    cloud = ''
    tags.each do |tag|
      size = min_size + (tag["count"] - lowest_value["count"]) * ratio
      url = custom_posts(tag["name"], params[:author])
      cloud << "<li>#{link_to(tag["name"], url,
          :style => "font-size:#{size}px", :class => "#{tag_class}")}</li> "
    end
    cloud += ""
    cloud
  end

  def writers_links
    AppConfig.author["writers"].
          map {|w| link_to(w[0].to_s.capitalize+' '+w[1],
               custom_posts(nil,w[0].to_s.capitalize))}.join(', ')
  end

  def writers(author)
    unless author
      AppConfig.author["writers"].
            map {|w| w[0].to_s.capitalize+' '+w[1]}.join(', ')
    else
      fullname(author)
    end
  end

  def author_link(comment)
    unless comment.author_url.empty?
      "<a href='#{comment.author_url}' rel='nofollow'>#{comment.author}</a>"
    else
      comment.author
    end
  end
end
