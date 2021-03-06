class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :mark_unread_messages_as_read, :only => :show
  
  def index
    @messages = Message.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id).order("updated_at DESC")
  end

  def show
    @message = Message.find params[:id]
    if current_user == @message.sender || current_user == @message.receiver
      if current_user == @message.sender
        @person = @message.receiver
      else
        @person = @message.sender
      end
      @responses = @message.responses.where("origin != ?", "robot").order("created_at ASC")
      @response = Response.new
    else
      redirect_to root_path, :notice => "Sorry, you're not allowed to be there!"
    end
  end
  
  def mark_unread_messages_as_read
    @message = Message.find params[:id]
    @message.responses.each do |response|
      if current_user == response.replyee
        response.update_attributes(:state => "read")
      end
    end
  end

end
