class PostmarkMailer < ApplicationMailer
  default from: Rails.application.credentials.sender_signature

  def email
    @body = params[:body]

    return mail(
      subject: params[:subject],
      to: Rails.application.credentials.recipient,
      reply_to: Rails.application.credentials.reply_to_postmark,
      references: params[:references] || nil,
      in_reply_to: params[:in_reply_to] || nil,
      track_opens: 'true',
      message_stream: 'outbound'
    )
  end
end
