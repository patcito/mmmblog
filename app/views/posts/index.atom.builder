atom_feed(
  :url         => custom_atom_posts(@tag,@author),
  :root_url    => custom_posts(@tag,@author, :only_path => false),
  :schema_date => '2008'
) do |feed|
  feed.title     posts_title(@post, @tag, @author)
  feed.updated   @posts.empty? ? Time.now.utc : @posts.collect(&:edited_at).max
  feed.generator "mmblog", "uri" => AppConfig.site

  feed.author do |xml|
    xml.name  writers(@author)
    xml.email AppConfig.author["email"] unless AppConfig.author["email"].nil?
  end

  @posts.each do |post|
   feed.entry(post, :url => post_slug_path(post, @tag, @author, :only_path => false), :published => post.published_at, :updated => post.edited_at) do |entry|
      entry.title   post.title
      entry.content post.body_html, :type => 'html'
    end
  end
end