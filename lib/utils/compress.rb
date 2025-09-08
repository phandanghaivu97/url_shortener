module Utils
  module Compress
    class << self
      # Compresses the given text using Zlib deflate.
      #
      # @param text [String] the input text to be compressed and encoded
      # @return [String] the compressed string.
      def encode(text)
        Zlib::Deflate.deflate(text)
      end

      # Decodes a compressed string.
      #
      # @param compressed_text [String] The compressed text.
      # @return [String] The original, decompressed string.
      # @raise [Zlib::DataError] If the input is not valid compressed data.
      def decode(compressed_text)
        Zlib::Inflate.inflate(compressed_text)
      end
    end
  end
end
