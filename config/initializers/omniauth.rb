require 'dotenv'
Rails.application.config.middleware.use OmniAuth::Builder do
  Dotenv.load
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end
