class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:encode, :decode]

  def index; end

  def encode
    shortened_url = ShortenedUrl.create_from_long_url!(params[:original_url])

    render json: shortened_url, serializer: ShortenedUrl::EncodeSerializer, status: :created
  end

  def decode
    render json: {original_url:}, status: :created
  end

  def show
    redirect_to original_url, allow_other_host: true
  end

  private

  def original_url
    @original_url ||= Rails.cache.fetch(["shortened_url", params[:identifier]], expires_in: 12.hours) do
      ShortenedUrl.find_by!(identifier: params[:identifier]).decompress_original_url
    end
  end
end