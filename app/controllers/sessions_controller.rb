class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    user = User.find_by(provider: auth['provider'], uid: auth['uid'])
    unless user
      user = User.create_with_omniauth(auth)
      reminders = Reminder.where(uid: user.uid)
      p reminders
      reminders.each do |reminder|
        reminder.user_id = user.id
        reminder.save
      end
    end

    session[:user_id] = user.id
    redirect_to root_url, notice: 'login'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'logout'
  end
end
