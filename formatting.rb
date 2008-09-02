module DBNL
  module Formatting
    class Emphasis < DBNL::Structure::TextNode
      attr_reader :text
      def initialize(text)
        @text = text
      end

      def to_s
        @text.to_s
      end
    end

    class Italic < Emphasis
    end

    class Bold < Emphasis
    end

    class SmallCaps < Emphasis
      def to_s
        @text.upcase
      end
    end
  end
end
