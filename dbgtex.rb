require 'rip_dbnl'
require 'latex_formatter'

#book = DBNL::Parser.new.create_book 'http://www.dbnl.org/tekst/wolf016hist01_01/'
#open('burgerhart.bin', 'w') { |f| f << Marshal.dump(book) }
book = Marshal.load open('burgerhart.bin').read
tex  = DBNL::Formatters::LatexFormatter.new book
tex.save 'burgerhart.tex'
