class TestMailer < ApplicationMailer
  default from: Rails.application.credentials.sender_signature

  def hello
    mail(
      subject: 'Hello from Postmark',
      to: Rails.application.credentials.recipient,
      reply_to: Rails.application.credentials.reply_to_postmark,
      track_opens: 'true',
      message_stream: 'outbound'
    )
  end
end
