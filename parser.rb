%w(rubygems hpricot htmlentities structure formatting text_formatter open-uri).each { |l| require l }

class Array
  def map_with_index(&block)
    final = []
    each_with_index { |e, i| final << block.call(e, i) }
    final
  end
end

module DBNL
  class Parser
    attr_reader :book
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
            heading = Structure::MainHeading.new parse_heading(h3)
            headings << heading
          end

          (div/"div[@class='tekst-blok'"/'h4').each do |h4|
            heading = Structure::SecondaryHeading.new parse_heading(h4)
            headings << heading
          end

          (div/"div[@class='tekst-blok']"/'p').each do |p|
            para = Structure::Paragraph.new parse_paragraph(p)
            para.receded = true unless p.attributes['class'] == 'indent'
            page.paragraphs << para
          end
        end
      end
      [headings, pages]
    end

    def parse_heading(heading)
      nodes = []
      heading.children.each do |portion|
        next if !portion.is_a?(Hpricot::Text) && portion.stag.name == 'a'
        if portion.is_a?(Hpricot::Text)
          nodes << Structure::TextNode.new(HTMLEntities.decode_entities(portion.to_html))
        else
          if portion.children.size == 1 &&
              portion.children.first.is_a?(Hpricot::Text)
            nodes << define_emphasis(portion)
          else
            nodes += parse_heading(portion)
          end
        end
      end
      nodes
    end

    def parse_paragraph(para)
      nodes = []
      para.children.each_with_index do |portion, i|
        next if !portion.is_a?(Hpricot::Text) && portion.stag.name == 'a' or portion.nil?
        if portion.is_a?(Hpricot::Text)
          nodes << Structure::TextNode.new(clean_text(portion.to_html))
        else
          if !(img = (portion/"img[@alt='illustratie']").first).nil?
            url = img.attributes['src']
            caption = if para.children[i + 2] &&
                          para.children[i + 2].stag.name == 'small'
                        text = para.children[i + 2].inner_html
                        para.children[i + 2] = nil
                        clean_text text
                      else
                        nil
                      end
            nodes << Structure::Image.new(url, caption)
          elsif portion.stag.name == 'img'
            puts "IMAGE! #{portion.inspect}"
          else
            nodes << define_emphasis(portion)
          end
        end
      end
      nodes
    end

    def define_emphasis(fragment)
#      puts fragment.inner_html
      if fragment.is_a?(Hpricot::Text)
        Structure::TextNode.new(clean_text(fragment.to_html))
      else
        nodes = []
        fragment.children.each { |piece| nodes << define_emphasis(piece) }
        formatting_class(fragment).new nodes
      end
    end

    def clean_text(fragment)
      text = HTMLEntities.decode_entities(fragment)
      clean = text.gsub(/^\n*/, '').gsub(/\n*$/, ' ')
      clean
    end

    def formatting_class(fragment)
      case fragment.stag.name.to_sym
      when :i
        Formatting::Italic
      when :b
        Formatting::Bold
      when :span
        if fragment.attributes['class'] == 'small-caps'
          Formatting::SmallCaps
        else
          Structure::Container
        end
      when :br
        Formatting::NewLine
      when :small
        Formatting::Small
      else
        puts "ELSE! ELSE! ELSE! ELSE!: #{fragment.inspect}"
        #open('exceptions', a) { |f| f << "ELSE! ELSE! ELSE! ELSE!: #{fragment.inspect}" }
        Structure::TextNode
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
