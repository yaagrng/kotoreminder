class Kotori
  attr_accessor :stream, :rest

  def initialize
    @stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end

    @rest = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def tweet(user: nil, text: nil)
    if user
      @rest.update("@#{user} #{text}")
    else
      @rest.update("#{text}")
    end
  end

  def is_reminder?(user, text)
    split_text = text.split(/\s|　/, 3)
    # リマインダーらしき書式のとき
    if split_text[1] =~ /\d{12}/ and split_text.length == 3
      time = split_text[1].to_i
      split_now = Time.now.to_s.split(/\s|:|-/, 5)
      now = split_now.join.to_i
      time_text = [split_text[1][0, 4].to_i, split_text[1][4, 2].to_i, split_text[1][6, 2].to_i,
                    split_text[1][8, 2].to_i, split_text[1][10, 2].to_i]
      if time_text[1] > 12 or time_text[2] > 31 or time_text[3] > 23 or time_text[4] > 59
        tweet(user: user, text: "時間の書き方をもう一度見直してくれませんか？")
        return false
      elsif time <= now
        text = time_format(time_text)
        tweet(user: user, text: "#{text}...えーっと、過去には送れないんです。")
        return false
      elsif time_text[0] > split_now[0].to_i + 4
        time = split_now[0].to_i + 4
        tweet(user: user, text: "#{time}年までなら頑張って覚えられます！")
        return false
      else #リマインダーとして処理
        text = time_format(time_text)
        tweet(user: user, text: "#{text}に連絡します")
        return true
      end
    end
  end

  def time_format(time_text)
    str = ""
    time_text.each_with_index do |text, i|
      str << text.to_i.to_s
      if i == 0
        str << "年"
      elsif i == 1
        str << "月"
      elsif i == 2
        str << "日"
      elsif i == 3
        str << "時"
      elsif i == 4
        str << "分"
      end
    end
    return str
  end

  def random_string
    str = %w(ホノカチャン ホノカ ほのか ほの ウミチャン うみ えりちゃん)
    return str[rand(str.length)]
  end
end
