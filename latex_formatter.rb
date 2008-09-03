require 'stringio'
module DBNL::Formatters
  class LatexFormatter
    def initialize(book)
      @book = book
    end

    def save(filename)
      tex = format
      open(filename, 'w') { |f| f << tex }
    end

    def format
      tex = ""
      tex << "\\documentclass[a4paper,dutch]{book}\n"
      tex << "\\usepackage{babel}\n"
      tex << "\\usepackage{ucs}\n"
      tex << "\\usepackage{fontspec}\n"
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
                 para.nodes.map { |node| emphasize node }.join
               end.join("\n\n")
        tex << "\n"
      end
      tex << "\\end{document}\n"
      tex
    end

    def emphasize(node)
      if node.instance_of?(DBNL::Structure::TextNode)
        clean_text node.to_s
      else
        if node.is_a?(DBNL::Formatting::NewLine)
          ""
        else
          node.nodes.map do |node|
            case node
            when DBNL::Structure::Container
              emphasize node
            when DBNL::Formatting::SmallCaps
              "{\\sc #{emphasize node}}"
            when DBNL::Formatting::Italic
              "{\\it #{emphasize node}}"
            when DBNL::Formatting::Bold
              "{\\bf #{emphasize node}}"
            when DBNL::Formatting::Small
              "{\\small #{emphasize node}}"
            when DBNL::Structure::TextNode
              clean_text(node.to_s)
            end
          end.join
        end
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
