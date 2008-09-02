require 'rip_dbnl'

book = DBNL::Parser.new.create_book 'http://www.dbnl.org/tekst/wolf016corn01_01/'
open('wolff.bin', 'w') { |f| f << Marshal.dump(book) }
