xml.instruct! :xml, version: "1.0"
xml.rss(version: "2.0", :"xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.description feed.description
    xml.title "[Reblog-free] #{feed.title}"
    xml.generator "Reblog-free Tumblr (1.0, @#{username})"
    xml.link feed.url

    if entries.any?
      entries.each do |post|
        xml.item do
          xml.title post.title
          xml.description post.summary
          xml.link post.url
          xml.guid post.url
          xml.pubDate post.published.rfc822
        end
      end
    else
      xml.item do
        xml.title "No posts at the moment"
        xml.description "This is just to make feed valid."
        xml.link feed.url
        xml.guid feed.url
        xml.pubDate Time.new.rfc822
      end
    end
  end
end
