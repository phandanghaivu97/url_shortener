module Utils
  module Compress
    class << self
      def encode(text)
        Zlib::Deflate.deflate(text)
      end

      def decode(compressed_text)
        Zlib::Inflate.inflate(compressed_text)
      end
    end
  end
end
