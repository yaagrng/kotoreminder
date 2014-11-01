class RemindersController < ApplicationController
  before_action :reminder_select, only: :destroy
  def create
  end

  def destroy
    @reminder.destroy
    redirect_to user_path
  end

  private
  def reminder_select
    @reminder = Reminder.find_by(id: params[:id])
    redierct_to root_url if @reminder.nil?
  end
end
