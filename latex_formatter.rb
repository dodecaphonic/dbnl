require 'rubygems'
require 'structure'
require 'formatting'
require 'open-uri'
require 'RMagick'

module DBNL::Formatters
  class LatexFormatter
    def initialize(book)
      @book = book
    end

    def save(projectname)
      path = File.join('boeken', projectname)
      filename = File.join path, "#{projectname}.tex"
      Dir.mkdir path if !File.exist? path
      tex = format(path)
      open(filename, 'w') { |f| f << tex }
#      `xelatex #{filename}`
    end

    def format(path=nil)
      tex = ""
      tex << "\\documentclass[a4paper,dutch]{book}\n"
      tex << "\\usepackage{babel}\n"
      tex << "\\usepackage{ucs}\n"
      tex << "\\usepackage{fontspec}\n"
      tex << "\\usepackage[final,xetex]{graphicx}\n"
#      tex << "\\setmainfont{Apple Garamond}\n"
#      tex << "\\usepackage[utf8x]{inputenc}\n"
      tex << "\\title{#{@book.title}}\n"
      tex << "\\author{#{@book.author}}\n"
#      tex << "\mainmatter\n"
      tex << "\\begin{document}\n"
      tex << "\\maketitle\n"
      tex << "\\tableofcontents\n"
      tex << "\n"
      @book.chapters.each do |chapter|
        tex << "\\chapter{#{chapter.title}}\n\n"
        tex << chapter.paragraphs.map do |para|
                 para.nodes.map do |node|
                   if node.respond_to? :caption
                     insert_image node, path
                   else
                     emphasize node
                   end
                 end.join
               end.join("\n\n")
        tex << "\n"
      end
      tex << "\\end{document}\n"
      tex
    end

    def insert_image(node, path)
      Dir.mkdir(File.join(path, 'images')) unless File.exist? 'images'
      filename = File.join 'images', node.filename
      filename = filename.split('.')[0..-2].join + '.jpg'
#      puts #{@book.url}/node.
      i = Magick::Image.from_blob(open("#{@book.url}/#{node.filename}").read).first
      i.write filename
      caption = node.caption ? "\\caption{#{node.caption.to_s}}" : ''
      %Q|
         \\begin{figure}[h!]
           \\centering
             \\includegraphics{#{filename}}
           #{caption}
         \\end{figure}
        |
    end

    def emphasize(node)
      if node.instance_of?(DBNL::Structure::TextNode) || node.respond_to?(:upcase)
        clean_text node.to_s
      elsif node.is_a?(DBNL::Formatting::NewLine)
        ""
      else
        base = case node
               when DBNL::Structure::Container
                 "%s"
               when DBNL::Formatting::SmallCaps
                 "{\\sc %s}"
               when DBNL::Formatting::Italic
                 "{\\it %s}"
               when DBNL::Formatting::Bold
                 "{\\bf %s}"
               when DBNL::Formatting::Small
                 "{\\small %s}"
               end
        internal = node.nodes.map { |part| emphasize part }.join
        base % internal
      end
    end

    def clean_text(text)
      clean = text.gsub('&', '\\\\&').
                   gsub('$', '\$').
                   gsub('%', '\%').
                   gsub('#', '\#').
                   gsub('_', '\_').
                   gsub('{', '\{').
                   gsub('}', '\}').
                   gsub('...', '\ldots')#.
#                   gsub('ƒ', 'f')
      clean
    end
  end
end
