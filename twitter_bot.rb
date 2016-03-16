class TwitterBot
  attr_accessor :client, :options
  attr_accessor :id, :user
  def initialize(auth_info_lambda, options: {})
    @client = Twitter::REST::Client.new do |config|
      auth_info_lambda.call(config)
    end
    @options = options
    @options[:once_follow] ||= 150
    @id = options[:id]
  end
  RUBY_TWR = TwitterBot.new ->(client_config) {
    client_config.consumer_key        = Token::CONSUMER_KEY
    client_config.consumer_secret     = Token::CONSUMER_SECRET
    client_config.access_token        = Token::ACCESS_TOKEN
    client_config.access_token_secret = Token::ACCESS_TOKEN_SECRET
  }, options: {id: "Ruby_twr"}
  ACCOUNTS = {
      RUBY_TWR.id => RUBY_TWR,
  }

  class << self
    def id
      @id ||= @user.id
    end

    def user
      @user ||= @client.user
    end

    def tweet(msg)
      @client.update msg
    end

    # for delayed job
    def self.milktea_follow(target_ids)
      client = MANGA_MILKTEA.client
      target_ids = [target_ids] if ! target_ids.is_a? Array
      client.follow target_ids
      logger.info "#{target_ids.count} followed completed."
    end


    def follow(target_ids)
      target_ids = [target_ids] if ! target_ids.is_a? Array
      @client.follow target_ids
      logger.info "#{target_ids.count} followed completed."
    end

    def search(*args)
      @client.search *args
    end

    def mentions_timeline
      @client.mentions_timeline
    end

    def user_timeline
      @client.user_timeline
    end

    def direct_messages_received
      @client.direct_messages_received
    end

    def unfollow(target_ids)
      target_ids = [target_ids] if ! target_ids.is_a? Array
      @client.unfollow target_ids
      logger.info "#{target_ids.count} unfollowed completed."
    end

    def logger
      TwitterBot.logger
    end

    def self.logger
      Delayed::Worker.try(:logger) || Rails.logger
    end
  end
end
