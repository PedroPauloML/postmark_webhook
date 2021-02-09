class EmailsController < ApplicationController
  before_action :set_email, only: %i[ show edit update destroy ]

  # GET /emails or /emails.json
  def index
    @emails = Email.all
  end

  # GET /emails/1 or /emails/1.json
  def show
  end

  # GET /emails/new
  def new
    @email = Email.new(email_id: params[:reply_to])
  end

  # GET /emails/1/edit
  def edit
  end

  # POST /emails or /emails.json
  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html {
          in_reply_to = @email.email
          references = ((in_reply_to&.references || []) + ([in_reply_to&.message_id]))
          references = references
            .flatten
            .reject(&:nil?)
            .reject(&:blank?)
            .uniq

          postmark_email = PostmarkMailer
            .with(
              subject: @email.subject,
              body: @email.body,
              references: references.join(','),
              in_reply_to: in_reply_to&.message_id
            )
            .email
            .deliver_now

          @email.references = [
              [postmark_email.references.try(:split, ",") || ""]
                .flatten
                .reject(&:nil?)
                .reject(&:blank?)
                .uniq
                .collect {|ref| "<#{ref.gsub(/[<>]/, '')}>"},
              postmark_email.in_reply_to.present? ? "<#{postmark_email.in_reply_to.gsub(/[<>]/, '')}>" : nil
            ]
            .flatten
            .reject(&:nil?)
            .reject(&:blank?)
            .uniq
          @email.in_reply_to = postmark_email.in_reply_to ? "<#{postmark_email.in_reply_to.gsub(/[<>]/, '')}>" : nil
          @email.message_id = "<#{postmark_email.message_id.gsub(/[<>]/, '')}>"
          @email.email_data = postmark_email.to_postmark_hash
          @email.save

          redirect_to @email, notice: "Email was successfully created."
        }
        format.json { render :show, status: :created, location: @email }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /emails/1 or /emails/1.json
  def update
    respond_to do |format|
      if @email.update(email_params)
        format.html { redirect_to @email, notice: "Email was successfully updated." }
        format.json { render :show, status: :ok, location: @email }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1 or /emails/1.json
  def destroy
    @email.destroy
    respond_to do |format|
      format.html { redirect_to emails_url, notice: "Email was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email
      @email = Email.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def email_params
      params.require(:email).permit(:subject, :body, :email_id)
    end
end
