require "cuba"
require "cuba/render"
require "slim"
require "securerandom"
require "rack/protection"
require "clogger"
require "feedjira"
require "open-uri"

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
      entries = feed.entries.delete_if do |entry|
        contents = open(entry.url).read
        contents =~ /reblogged (.*) ago from/i
      end

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
