class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process_from_postmark
    references = @email["Headers"].find {|header| header["Name"] == "References"}
    in_reply_to = @email["Headers"].find {|header| header["Name"] == "In-Reply-To"}
    message_id = @email["Headers"].find {|header| header["Name"] == "Message-ID"}

    # puts "\n--- DATA FROM E-MAIL---"
    # puts "\n>>> To: #{@email['To']}"
    # puts "\n>>> From: #{@email['From']}"
    # puts "\n>>> Subject: #{@email['Subject']}"
    # puts "\n>>> Text Body: #{@email['TextBody']}"
    # puts "\n>>> Html Body: #{@email['HtmlBody']}"
    # puts "\n>>> Attachments: #{@email['Attachments']}"
    # puts "\n>>> References: #{references ? references["Value"] : "-"}"
    # puts "\n>>> In-Reply-To: #{in_reply_to ? in_reply_to["Value"] : "-"}\n\n"
    # puts "\n>>> Message-ID: #{message_id ? message_id["Value"] : "-"}\n\n"

    new_email = Email.create(
      subject: @email['Subject'],
      body: @email['TextBody'],
      references: references ? references["Value"].split(',') : nil,
      in_reply_to: in_reply_to ? in_reply_to["Value"] : nil,
      message_id: message_id ? message_id["Value"] : nil,
      email_data: @email,
      email: message_id ? Email.find_by(message_id: references["Value"].split(',').last) : nil,
    )

    @email['Attachments'].each do |attachment|
      content = Base64.decode64(attachment['Content'])
      File.open(Rails.root.join("lib/assets/#{attachment['Name']}"), 'wb') do |file|
         file.write(content)
      end
      opened_file = Pathname.new(Rails.root.join("lib/assets/#{attachment['Name']}")).open
      File.delete(Rails.root.join("lib/assets/#{attachment['Name']}"))

      new_email.attachments.attach(
        io: opened_file,
        filename: attachment['Name'],
        content_type: attachment['ContentType'],
      )
    end
  end

  def process_from_sendgrid
    to = @email["to"].match(/"(.+)"/)&.captures&.first
    from = @email["from"].match(/<(.+)>/)&.captures&.first
    subject = @email["subject"]
    text_body = @email["text"]
    html_body = @email["html"]
    attachements = []
    @email["attachments"].to_i.times do |i|
      attachements << @email["attachment#{i+1}"] if @email["attachment#{i+1}"]
    end
    references = @email["headers"].match(/References: (.+)/)&.captures&.first
    in_reply_to = @email["headers"].match(/In-Reply-To: (.+)/)&.captures&.first
    message_id = @email["headers"].match(/Message-ID: (.+)/)&.captures&.first

    # puts "\n--- DATA FROM E-MAIL---"
    # puts "\n>>> params: #{@email.to_json}"
    # puts "\n>>> To: #{to}"
    # puts "\n>>> From: #{from}"
    # puts "\n>>> Subject: #{subject}"
    # puts "\n>>> Text Body: #{text_body}"
    # puts "\n>>> Html Body: #{html_body}"
    # puts "\n>>> Attachments: #{attachements.count} attachment(s)"
    # puts "\n>>> References: #{references || "-"}"
    # puts "\n>>> In-Reply-To: #{in_reply_to || "-"}\n\n"
    # puts "\n>>> Message-ID: #{message_id || "-"}\n\n"

    new_email = Email.create(
      subject: subject,
      body: text_body,
      references: references ? references.split(',') : nil,
      in_reply_to: in_reply_to,
      message_id: message_id,
      email_data: @email,
      email: references ? Email.find_by(message_id: references.split(',').last) : nil,
    )
    attachements.each do |attachment|
      new_email.attachments.attach(attachment)
    end
  end
end