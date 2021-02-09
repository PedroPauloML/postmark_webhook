json.extract! email, :id, :subject, :body, :email_data, :email_id, :created_at, :updated_at
json.url email_url(email, format: :json)
