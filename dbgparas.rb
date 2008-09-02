require 'rip_dbnl'
require 'pdf_formatter'
require 'text_formatter'

book = Marshal.load open("wolff.bin").read
paras = book.chapters.first.paragraphs
pdf  = DBNL::Formatters::PDFFormatter.new book
txt  = DBNL::Formatters::TextFormatter.new book
pdf.save 'wolff.pdf'
txt.save 'wolff.txt'
