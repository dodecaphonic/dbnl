module DBNL::Formatters
  class TextFormatter
    def initialize(book)
      @book = book
      @format = nil
    end

    def format
      return @format unless @format.nil?
      @format = ""
      @book.chapters.each do |c|
        @format << "#{c.title}\n"
        c.pages.each { |p| @format << p.to_s }
        @format
      end
    end

    def save(filename)
      open(filename, 'w') { |f| f << format }
    end
  end
end
