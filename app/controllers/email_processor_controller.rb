class EmailProcessorController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :token_valid?

  def create
    email = ::EmailProcessor.new(params)
    email.process
    render json: {}, status: :ok
  end

  private

  def token_valid?
    params[:token].present? and params[:token] == 'postmark'
  end
end
