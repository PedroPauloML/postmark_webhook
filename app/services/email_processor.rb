class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    references = @email["Headers"].find {|header| header["Name"] == "References"}
    in_reply_to = @email["Headers"].find {|header| header["Name"] == "In-Reply-To"}

    puts "\n--- DATA FROM E-MAIL---"
    puts "\n>>> To: #{@email['To']}"
    puts "\n>>> From: #{@email['From']}"
    puts "\n>>> Subject: #{@email['Subject']}"
    puts "\n>>> Text Body: #{@email['TextBody']}"
    puts "\n>>> Html Body: #{@email['HtmlBody']}"
    puts "\n>>> Attachments: #{@email['Attachments']}"
    puts "\n>>> References: #{references ? references["Value"] : "-"}"
    puts "\n>>> In-Reply-To: #{in_reply_to ? in_reply_to["Value"] : "-"}\n\n"
  end
end