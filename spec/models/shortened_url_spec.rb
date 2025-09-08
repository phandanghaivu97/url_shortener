require "rails_helper"

RSpec.describe ShortenedUrl, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:original_url) }
    it { is_expected.to validate_length_of(:original_url).is_at_most(5000) }

    [
      "http://example.com",
      "https://example.com",
      "http://www.example.com",
      "https://www.example.com/path",
      "https://subdomain.example.com/path?param=value"
    ].each do |valid_url|
      it "treats #{valid_url} as an valid url" do
        shortened_url = ShortenedUrl.new(original_url: valid_url)
        expect(shortened_url).to be_valid
      end
    end

    [
      "ftp://example.com",
      "example.com",
      "mailto:test@example.com",
      "invalid-url"
    ].each do |invalid_url|
      it "returns invalid error for #{invalid_url}" do
        shortened_url = ShortenedUrl.new(original_url: invalid_url)
        expect(shortened_url).not_to be_valid
        expect(shortened_url.errors[:original_url]).not_to be_empty
      end
    end
  end

  describe "instance methods" do
    let(:shortened_url) { ShortenedUrl.new(original_url: "https://example.com") }

    describe "#generate_identifier" do
      it "generates a 6 character alphanumeric identifier" do
        allow(SecureRandom).to receive(:alphanumeric).with(6).and_return("AbcXy6")

        shortened_url.generate_identifier
        expect(shortened_url.identifier).to eq "AbcXy6"
      end
    end

    describe "#compress_original_url" do
      it "compresses the original URL using Utils::Compress.encode" do
        allow(Utils::Compress).to receive(:encode).with("https://example.com").and_return("compressed_data")

        shortened_url.compress_original_url
        expect(shortened_url.compressed_original_url).to eq("compressed_data")
      end
    end

    describe "#decompress_original_url" do
      it "decompresses the original URL using Utils::Compress.decode" do
        allow(Utils::Compress).to receive(:decode).with("compressed_data").and_return("https://example.com")

        shortened_url.original_url = nil
        shortened_url.compressed_original_url = "compressed_data"
        shortened_url.decompress_original_url

        expect(shortened_url.original_url).to eq("https://example.com")
      end
    end
  end

  describe ".shortify!" do
    let(:long_url) { "https://example.com/very/long/path" }

    it "creates a new ShortenedUrl with valid URL" do
      shortened_url = ShortenedUrl.shortify!(long_url)
      expect(shortened_url).to be_persisted
      expect(shortened_url.original_url).to eq(long_url)
      expect(shortened_url.identifier).to be_present
      expect(shortened_url.compressed_original_url).to be_present
    end

    it "raises ActiveRecord::RecordInvalid for invalid URLs" do
      expect {
        ShortenedUrl.shortify!("ftp://invalid-protocol.com")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "when identifier is existed" do
      it "handles identifier collision by regenerating identifier" do
        first_url = ShortenedUrl.shortify!(long_url)

        allow(SecureRandom).to receive(:alphanumeric).with(6).and_return(first_url.identifier, "newid1")

        second_url = ShortenedUrl.shortify!("https://different-url.com")
        expect(second_url).to be_persisted
        expect(second_url.identifier).not_to eq(first_url.identifier)
      end

      context "when the regenerating exceeds the retries" do
        let(:first_url) {ShortenedUrl.shortify!(long_url)}

        before do
          allow(SecureRandom).to receive(:alphanumeric).with(6).and_return(first_url.identifier)
          allow(Rails.logger).to receive(:error)
        end

        it "retries up to MAX_COLLITION_RETRIES times when identifier collision occurs, then raises error" do
          expect { ShortenedUrl.shortify!("https://different.com") }.to raise_error(ActiveRecord::RecordNotUnique)
          expect(SecureRandom).to have_received(:alphanumeric).with(6).exactly(3).times
          expect(Rails.logger).to have_received(:error).with("Identifier collision after 3 attempts.")
        end
      end
    end

    context "when compressed_original_url is existed" do
      it "returns existing ShortenedUrl when compressed_original_url already exists" do
        first_url = ShortenedUrl.shortify!(long_url)
        second_url = ShortenedUrl.shortify!(long_url)

        expect(second_url.id).to eq(first_url.id)
        expect(second_url).to eq(first_url)
      end
    end
  end
end
