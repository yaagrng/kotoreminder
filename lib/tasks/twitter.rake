namespace :twitter do
  desc "リプライを見てDBに保存する"

  task :save_reply => :environment do
    TweetStream.configure do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.oauth_token = ENV["TWITTER_ACCESS_TOKEN"]
      config.oauth_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
      config.auth_method = :oauth
    end
    kotori = TweetStream::Client.new
    begin
      kotori.userstream do |status|
        contents = status.text
        if(/^@kotoreminder/.match(contents))
          #text[0] : "@kotoreminder", text[1] : 日付, text[2] : 内容
          text = status.text.split(/\s|　/, 3)
          now = Time.now.to_s.split(/\s|:|-/)[0..4].join.to_i
          time = text[1].to_i

          if text[1] =~ /\d{12}/ and time > now and text.length == 3
            user = User.find_by(uid: status.user.id)
            user_id = nil
            if user
              user_id = user.id
            end
            reminder = Reminder.new(content: text[2], time: time, 
                                    user_id: user_id, uid: status.user.id)
            begin
              reminder.save!
              puts "create #{stauts.user.screen_name}'s tweet content=#{reminder.content}"
              puts "user_id = #{user_id}"
            rescue => ex
              puts ex.message
            end
          end
        end
      end
      now = Time.now.to_s.split(/\s|:|-/)[0..4].join.to_i
      reminders = Reminder.where(time: now)
      reminders.each do |reminder|
        rep_text = "@#{reminder.user.name}  \"#{reminder.content}\"　ですよ！"
        kotori.update(rep_text, inreply_to_status_id: reminder.user.uid)
      end
    rescue => em
      puts Time.now
      p em
      sleep 2
      retry
    rescue Interrupt
      exit 1
    end
  end
end
