class ShortenedUrl < ApplicationRecord
  MAX_COLLITION_RETRIES = 3

  attribute :original_url

  validates :original_url, presence: true, length: { maximum: 5000 }
  validates :original_url, format: URI::regexp(["http", "https"]), allow_blank: true

  def generate_identifier
    self.identifier = SecureRandom.alphanumeric(6)
  end

  def compress_original_url
    self.compressed_original_url = Utils::Compress.encode(original_url)
  end

  def decompress_original_url
    self.original_url ||= Utils::Compress.decode(compressed_original_url)
  end

  private

  class << self
    def shortify!(long_url)
      shortened_url = new(original_url: long_url)
      raise ActiveRecord::RecordInvalid, shortened_url unless shortened_url.valid?

      shortened_url.generate_identifier
      shortened_url.compress_original_url

      retries = 0

      begin
        shortened_url.save!
      rescue ActiveRecord::RecordNotUnique => e
        violated_attribute = extract_unique_violation_attribute(e.message)

        case violated_attribute
        when "identifier"
          retries += 1

          if retries < MAX_COLLITION_RETRIES
            shortened_url.generate_identifier
            retry
          else
            # The number of tokens may be about to be depleted. Consider increasing the token length in this case.
            Rails.logger.error "Identifier collision after #{MAX_COLLITION_RETRIES} attempts."

            raise ActiveRecord::RecordNotUnique, "There is an unexpected error occured. Please try again."
          end
        when "compressed_original_url"
          return find_by(compressed_original_url: shortened_url.compressed_original_url)
        end
      end

      shortened_url
    end
  end
end
