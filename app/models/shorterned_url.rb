class ShorternedUrl < ApplicationRecord
  attribute :original_url

  validates :original_url, presence: true

  def self.create_from_long_url(original_url:)
    shorterned_url = new(original_url:)
    raise ActiveRecord::RecordInvalid, shorterned_url unless shorterned_url.valid?

    shorterned_url.generate_identifier
    shorterned_url.compressed_original_url

    begin
      shorterned_url.save!
    rescue ActiveRecord::RecordNotUnique => e
      violated_attribute = extract_unique_violation_attribute(e.message)

      case violated_attribute
      when "identifier"
        shorterned_url.generate_identifier
        retry
      when "compressed_original_url"
        return find_by(compressed_original_url: shorterned_url.compressed_original_url)
      end
    end
  end

  def generate_identifier
    self.identifier = SecureRandom.alphanumeric(6)
  end

  def compressed_original_url
    self.compressed_original_url = Utils::Compress.encode(original_url)
  end
end
