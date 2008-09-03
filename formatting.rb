module DBNL
  module Formatting
    class Emphasis < DBNL::Structure::TextNode
      attr_reader :nodes
      def initialize(text)
        @nodes = text
      end

      def text
        to_s
      end

      def to_s
        @nodes.map { |n| n.to_s }.join
      end
    end

    class Italic < Emphasis
    end

    class Bold < Emphasis
    end

    class SmallCaps < Emphasis
      def to_s
        super.upcase
      end
    end

    class NewLine
      def initialize(garbage)
      end
    end

    class Small < Emphasis
    end
  end
end
