%w(rubygems hpricot htmlentities structure formatting text_formatter open-uri).each { |l| require l }

module DBNL
  class Parser
    attr_reader :book
    def initialize
    end

    def create_book(book_url)
      scraper = Hpricot open(book_url)
      @book  = Structure::Book.new *extract_details(scraper)
      index = extract_chapter_list scraper
      done = []
      index.each do |name, url|
        base_url = url.split('#').first
        next if done.member? base_url
        url = book_url + (book_url =~ /\/$/ ? url : "/#{url}")
        chapter = Structure::Chapter.new name.gsub(/\n/, '').strip
        chapter.headings, chapter.pages = extract_pages url
        @book.chapters << chapter
        done << base_url
      end
      @book
    end

    private
    def extract_pages(url)
      scraper = Hpricot open(url)
      pages, headings = [], []
      content = (scraper/"div[@class='tekst-kolom']").first
      page = Structure::Page.new 0
      pages << page
      (content/"div[@class='tekst-en-noot-blok']").each do |div|
        unless (div/"div[@class='pb']").empty?
          page = Structure::Page.new div.inner_text.sub(/\[p. (\S+)\]/, '\1')
          pages << page
        else
          (div/"div[@class='tekst-blok'"/'h3').each do |h3|
            heading = Structure::MainHeading.new parse_text(h3)
            headings << heading
          end
          
          (div/"div[@class='tekst-blok'"/'h4').each do |h4|
            heading = Structure::SecondaryHeading.new parse_text(h4)
            headings << heading
          end

          (div/"div[@class='tekst-blok']"/'p').each do |p|
            para = Structure::Paragraph.new parse_text(p)
            para.receded = true unless p.attributes['class'] == 'indent'
            page.paragraphs << para
          end
        end
      end
      [headings, pages]
    end

    def parse_text(fragment)
      nodes = []
      fragment.children.each do |portion|
        next if !portion.is_a?(Hpricot::Text) && portion.stag.name == 'a'
        if portion.is_a?(Hpricot::Text)
          nodes << Structure::TextNode.new(HTMLEntities.decode_entities(portion.to_html))
        else
          if portion.children.empty?
            nodes << define_emphasis(portion)
          else
            nodes += parse_text(portion)
          end
        end
      end
      nodes
    end

    def define_emphasis(fragment)
      text = HTMLEntities.decode_entities(fragment.inner_html)
      tag  = fragment.stag
      case tag.name.to_sym
      when :i
        Formatting::Italic.new text
      when :b
        Formatting::Bold.new text
      when :span
        if fragment.attributes['class'] == 'small-caps'
          Formatting::SmallCaps.new(text)
        end
      end
    end

    def extract_chapter_list(scraper)
      ((scraper/"div[@class='tekstpagina-content']"/'table')[1]/'a').map do |c|
        [c.inner_text, c.attributes['href']]
      end
    end

    def extract_details(scraper)
      title = (scraper/"h1[@class='title']").inner_text.strip
      author = (scraper/"h2[@class='author']").inner_text.strip
      [title, author]
    end
  end
end

if __FILE__ == $0
  parser = DBNL::Parser.new
  book = parser.create_book 'http://www.dbnl.org/tekst/wolf016corn01_01/'
  formatter = DBNL::TextFormatter.new book
  formatter.save 'wolf.txt'
end
