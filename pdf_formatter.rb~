%w(rubygems prawn structure iconv).each { |l| require l }

module DBNL::Formatters
  class PDFFormatter
    FONTS = { :chapter_header => "fonts/DayRoman.ttf",
      :text => "fonts/AppleGaramond.ttf",
      :cover => "fonts/AppleGaramond-Light.ttf" }
    def initialize(book)
      @book = book
      @formatted = nil
    end

    def save(filename)
      format.render_file filename
    end

    def format
      pdf = Prawn::Document.new :page_size => "A5", :page_layout => :portrait
      draw_cover pdf
      #      return pdf
      pdf.start_new_page :left_margin => 50, :right_margin => 50, :top_margin => 70, :bottom_margin => 70
      @book.chapters.each_with_index do |chapter, ci|
        pdf.start_new_page :left_margin => 50, :right_margin => 50,
        :top_margin => 50, :bottom_margin => 50
        puts "Putting in #{chapter.title}: #{chapter.headings.inspect}"
        draw_chapter_header pdf, chapter
        pdf.font FONTS[:text]
        chapter.paragraphs.each do |para|
          ptext = para.to_s.gsub "\n", " "
          ptext = "        #{ptext}" unless para.receded
          pdf.text ptext, :size => 10
          #          pdf.start_new_page :left_margin => 50, :right_margin => 50, :top_margin => 50, :bottom_margin => 50
        end
      end
      @formatted = pdf
    end

    def draw_chapter_header(pdf, chapter)
      pdf.font FONTS[:chapter_header]
      chapter.headings.each do |heading|
        htext = heading.to_s
        if heading.is_a? DBNL::Structure::MainHeading
          pdf.text htext, :size => 16
        else
          pdf.text htext, :size => 14
        end
      end
    end

    def draw_cover(pdf)
      box = pdf.bounds
      pdf.rectangle [0, box.height], box.width, box.height
      pdf.stroke
      pdf.font "fonts/AppleGaramond-Light.ttf"
      pdf.pad_top(15) do
        pdf.font_size(18) { pdf.text @book.author, :align => :center }
      end
      pdf.pad_top(25) do
        pdf.font_size(30) { pdf.text @book.title.upcase, :align => :center }
      end
    end
  end
end
