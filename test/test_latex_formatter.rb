require 'test/unit'
require 'parser'
require 'latex_formatter'

module DBNL::Tests
  class TestLatexFormatter < Test::Unit::TestCase
    def setup
      @book = Marshal.load open('test/data/burgerhart.bin')
      @formatter = DBNL::Formatters::LatexFormatter.new @book
    end

    def test_emphasis
      node = DBNL::Formatting::Italic.new [DBNL::Structure::TextNode.new("I was called "), DBNL::Formatting::SmallCaps.new("joshua"), DBNL::Structure::TextNode.new(" when I was a young kid.")]
      assert_equal '{\it I was called {\sc joshua} when I was a young kid.}',
                   @formatter.emphasize(node)
    end
  end
end
