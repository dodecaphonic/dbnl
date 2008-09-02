require 'rip_dbnl'
include DBNL

p = Parser.new
chapter = 'http://www.dbnl.org/tekst/wolf016corn01_01/wolf016corn01_01_0006.htm'
pages, headings = p.send :extract_pages, chapter
