module DBNL
  module Structure
    class DocumentNode
    end

    class TextNode < DocumentNode
      attr_reader :text
      def initialize(text)
        @text = text
      end

      def to_s
        @text
      end
    end

    class Container < DocumentNode
      attr_reader :nodes
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |n| n.to_s }.join
      end
    end

    class ParagraphList < Array
      alias :org_push :push
      PUNCTUATION_END = /(\.|!|\?|(\.|\?|!)\342\200\231)(\s+)?$/
      def push(paragraph)
        latest = last
        unless latest.nil? or latest.to_s =~ PUNCTUATION_END
          latest.nodes += paragraph.nodes
        else
          org_push paragraph
        end
      end

      def <<(paragraph)
        push paragraph
      end

      def +(other)
        copy = self.dup
        other.each { |p| copy << p }
        copy
      end
    end

    class Paragraph < DocumentNode
      attr_accessor :receded, :nodes
      def initialize(nodes)
        @nodes = nodes
        @receded = false
      end

      def text
        to_s
      end

      def to_s
        @nodes.map { |n| n.to_s }.join
      end
    end

    class ImageNode < DocumentNode
      attr_reader :filename, :caption
      def initialize(filename, caption)
        @filename, @caption = filename, caption
      end
    end

    class Page < DocumentNode
      attr_reader :number, :paragraphs
      def initialize(number)
        @number = number
        @paragraphs = []
      end

      def to_s
        @paragraphs.map { |p| p.to_s }.join "\n"
      end
    end

    class Heading < DocumentNode
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |n| n.to_s }.join
      end
    end

    class MainHeading < Heading; end
    class SecondaryHeading < Heading; end

    class Chapter < DocumentNode
      attr_reader :title
      attr_accessor :pages, :headings
      def initialize(title)
        @title = title
        @pages = []
        @headings = []
      end

      def paragraphs
        org_paras = @pages.inject([]) { |p, n| p + n.paragraphs }
        paras = ParagraphList.new
        org_paras.each do |para|
          new_para = Paragraph.new para.nodes.dup
          paras << new_para
        end
        paras
      end

      def to_s
        "#{@title}\n\n" + @headings.map { |h| h.to_s }.join("\n") + "\n" + paragraphs.join("\n")
      end
    end

    class Book
      attr_reader :url, :chapters, :title, :author
      def initialize(book_url, title, author)
        @url = book_url
        @title = title
        @author = author
        @chapters = []
      end

      def to_s
        text = "#{title} - #{author}\n"
        text << @chapters.map { |c| c.to_s }.join("\n\n")
        text
      end
    end
  end
end
