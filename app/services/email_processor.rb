class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
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
end