require 'kotori.rb'
class Cron::Twitter
  def self.save_reply
    kotori = Kotori.new
    p kotori

    begin
      kotori.stream.user do |status|
        p status
        case status
        when Twitter::Tweet
          puts "#{status.text}"

          # ことりへリプライが飛んできたときの処理
          if /^@kotoreminder/ =~ status.text
            kotori.rest.follow(status.user.screen_name)
            # リプライの内容がリマインダーか
            if kotori.is_reminder?(status.user.screen_name, status.text)
              puts "a reminder comes"
              user = User.find_by(uid: status.user.id)
              user_id = nil
              if user
                user_id = user.id
              end
              text = status.text.split(/\s|　/, 3)
              reminder = Reminder.new(content: text[2], time: text[1].to_i, 
                                      user_id: user_id, uid: status.user.id,
                                      name: status.user.screen_name)
              begin
                reminder.save!
                puts "save :  #{status.user.screen_name}'s tweet content=#{reminder.content}"
              rescue => ex
                puts ex.message
              end
            # リマインダーでなかったときの処理
            else
              puts "no reminder"
              text = kotori.random_string
              puts "#{text}"
              kotori.tweet(user: status.user.screen_name, text: text)
            end
          end
        end
        now = Time.now.to_s.split(/\s|:|-/)[0..4].join.to_i
        reminders = Reminder.where("time <= ?",  now)
        reminders.each do |reminder|
          rep_text = "@#{reminder.name}  \"#{reminder.content}\"です！"
          kotori.rest.update(rep_text)
          begin
            reminder_name = reminder.name
            reminder_content = reminder.content
            Reminder.destroy(reminder)
            puts "destroy reminder #{reminder_name} : #{reminder_content}"
          rescue => ex
            puts ex.message
          end
          sleep 2
        end
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
