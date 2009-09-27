atom_feed(
  :url         => custom_atom_comments(@tag, @author, @post),
  :root_url    => custom_posts(@tag,@author, :only_path => false),
  :schema_date => '2008'
) do |feed|
  feed.title     posts_title(@post, @tag, @author)
  feed.updated   @comments.empty? ? Time.now.utc : @comments.collect(&:created_at).max
  feed.generator "mmblog", "uri" => AppConfig.site

  feed.author do |xml|
    xml.name  writers(@author)
    xml.email AppConfig.author["email"] unless AppConfig.author["email"].nil?
  end

  @comments.each do |comment|
   feed.entry(comment, :url => post_slug_path(comment.post, @tag, @author, {:only_path => false, :anchor =>comment.id}), :published => comment.created_at, :updated => comment.post.updated_at) do |entry|
      entry.title   "#{comment.author} said #{comment.body[0..15]}..."
      entry.content comment.body, :type => 'text'
    end
  end
end