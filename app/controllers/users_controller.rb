class UsersController < ApplicationController
  def show
    @user = current_user
    @reminders = current_user.reminders
  end
end
