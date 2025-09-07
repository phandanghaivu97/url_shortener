module Utils
  module Compress
    class << self
      # Compresses and encodes the given text using Zlib deflate and Base64 encoding.
      #
      # @param text [String] the input text to be compressed and encoded
      # @return [String] the compressed and Base64-encoded string
      def encode(text)
        compressed_text = Zlib::Deflate.deflate(text)
        [compressed_text].pack("m0")
      end

      # Decodes a compressed and Base64-encoded string.
      #
      # @param compressed_text [String] The compressed text, encoded in Base64.
      # @return [String] The original, decompressed string.
      # @raise [Zlib::DataError] If the input is not valid compressed data.
      def decode(compressed_text)
        Zlib::Inflate.inflate(compressed_text.unpack1("m"))
      end
    end
  end
end
