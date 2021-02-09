class CreateEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :body
      t.string :references, array: true, default: []
      t.string :in_reply_to
      t.string :message_id
      t.json :email_data
      t.references :email, foreign_key: true

      t.timestamps
    end
  end
end
