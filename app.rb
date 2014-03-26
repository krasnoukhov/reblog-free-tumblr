require "cuba"
require "cuba/render"
require "slim"
require "securerandom"
require "rack/protection"
require "clogger"
require "feedjira"

# Cuba plugins
Cuba.use Rack::Session::Cookie, secret: SecureRandom.hex(64)
Cuba.use Rack::Protection
if ENV["RACK_ENV"] != "production"
  Cuba.use Clogger, format: :Combined, path: "./log/requests.log", reentrant: true
end
Cuba.plugin Cuba::Render

# Configuration
Cuba.settings[:render][:template_engine] = :slim

# Routes
Cuba.define do
  on root do
    res.write render("views/index.slim")
  end

  on ":username.rss" do |username|
    feed = Feedjira::Feed.fetch_and_parse("http://#{username}.tumblr.com/rss")
    if feed.respond_to?(:entries)
      reblogged = {}
      multi = Curl::Multi.new

      feed.entries.each do |entry|
        easy = Curl::Easy.new(entry.url) do |curb|
          curb.follow_location = true
          curb.on_failure do
            reblogged[entry.url] = true
          end
          curb.on_complete do |data|
            reblogged[entry.url] = !!(data.body_str =~ /reblogged (.*) ago from/i)
          end
        end
        multi.add(easy)
      end

      multi.perform
      entries = feed.entries.select { |entry| !reblogged[entry.url] }

      res.headers["Content-Type"] = "text/xml; charset=utf-8"
      res.write render("views/username.builder",
        username: username,
        feed: feed,
        entries: entries,
      )
    else
      res.redirect "/"
    end
  end
end
