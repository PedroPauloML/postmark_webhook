class Email < ApplicationRecord
  # Relationships
  belongs_to :email, optional: true
  has_many :emails, dependent: :nullify

  # Active Storage
  has_many_attached :attachments

  # Validations
  validates_presence_of :subject, :body

  def emails_references
    Email.where(message_id: self.references)
  end
end
