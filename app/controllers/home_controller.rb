class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:encode, :decode]

  def index; end

  def encode
    shortened_url = ShortenedUrl.shortify!(params[:original_url])

    render json: shortened_url, serializer: ShortenedUrl::EncodeSerializer, status: :created
  end

  def decode
    render json: {original_url:}, status: :created
  end

  def show
    redirect_to original_url, allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    redirect_to "/404"
  end

  private

  def original_url
    @original_url ||= Rails.cache.fetch(["shortened_url", params[:identifier]], expires_in: 12.hours) do
      ShortenedUrl.find_by!(identifier: params[:identifier].split("/").last).decompress_original_url
    end
  end
end
