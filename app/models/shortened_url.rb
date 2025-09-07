class ShortenedUrl < ApplicationRecord
  attribute :original_url

  validates :original_url, presence: true

  def generate_identifier
    self.identifier = SecureRandom.alphanumeric(6)
  end

  def compress_original_url
    self.compressed_original_url = Utils::Compress.encode(original_url)
  end

  def decompress_original_url
    self.original_url ||= Utils::Compress.decode(compressed_original_url)
  end

  class << self
    def create_from_long_url!(long_url)
      shortened_url = new(original_url: long_url)
      raise ActiveRecord::RecordInvalid, shortened_url unless shortened_url.valid?

      shortened_url.generate_identifier
      shortened_url.compress_original_url

      begin
        shortened_url.save!
      rescue ActiveRecord::RecordNotUnique => e
        violated_attribute = extract_unique_violation_attribute(e.message)

        case violated_attribute
        when "identifier"
          shortened_url.generate_identifier
          retry
        when "compressed_original_url"
          return find_by(compressed_original_url: shortened_url.compressed_original_url)
        end
      end

      shortened_url
    end
  end
end
