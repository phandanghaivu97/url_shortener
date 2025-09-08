class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from StandardError, with: :render_error

  private

  def render_error error
    case error
    when ActiveRecord::RecordInvalid
      render json: {error: error.record.errors.full_messages}, status: :unprocessable_content
    when ActiveRecord::RecordNotFound
      render json: {error: "#{error.model.titleize} could not be found!"}, status: :not_found
    else
      Rails.logger.error "#{self.class.name}##{action_name} Encountered an error: #{error.message}"

      render json: {error: "Something went wrong. Please try again!"}, status: :bad_request
    end
  end
end
