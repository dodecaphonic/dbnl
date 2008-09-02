%w(rip_dbnl test/unit).each { |l| require l }

module DBNL
  class TestParser < Test::Unit::TestCase
    def setup
      parser = Parser.new
      @wolf = parser.create_book 'http://www.dbnl.org/tekst/wolf016corn01_01/'
      @anthierens = parser.create_book 'http://www.dbnl.org/tekst/anth004belg01_01/'
    end

    def test_book_details
      assert_equal "Historie van mejuffrouw Cornelia Wildschut. Deel 1", @wolf.title
      assert_equal "Betje Wolff en Aagje Deken", @wolf.author
      assert_equal "Het Belgische domdenken", @anthierens.title
      assert_equal "Johan Anthierens", @anthierens.author
    end

    def test_chapter_list
      chapters = @wolf.chapters
      assert_equal "Voorrede.", chapters[0].title
      assert_equal "Een- en- veertigste brief. Juffrouw cornelia wildschut, aan Juffrouw anna hofman.", chapters[-1].title
      chapters = @anthierens.chapters
      assert_equal "De opgezette Belg Biologieles", chapters[0].title
      assert_equal "En eeuwig bloeien de begonia's... Naschrift", chapters[-1].title
    end

    def test_pages
      chapter = @wolf.chapters.first
      assert_equal "lijker zijn? hierin ligt zeer zeker de oorzaak dat veelen wier oogmerk beter is dan hun doorzicht of oordeel, alles wat den naam draagt van Roman ongelezen veroordeelen, als behoorende tot het legio der nutlooze of schadelijke boeken, die ons, uit verscheidene oorden, met geheele baalen worden toegezonden.", chapter.pages[4].paragraphs.first.to_s
      chapter = @anthierens.chapters.first
      assert_equal "\342\200\230Kijk uw Belg goed in de ogen en prent uzelf de kleur ervan in het geheugen, zodat u straks, wanneer de echte kleuren zijn verbleekt, de juiste kunstogen kunt kiezen. Om beschadiging te voorkomen doodt u zonodig de Belg onder een kaasstolp met gas. Stop alle lichaamsopeningen dicht met watten en laat het lichaam in de zon drogen. Eenmaal droog opent u de Belg via een snede midden over de borst. Knip de opperarm los met een nijptang en stroop de huid af. Spieren verwijdert u met een mesje; de hersenen lepelt u uit het achterhoofdsgat. Rol de huid, onder kwistig gebruik van conserveringsmiddelen, terug en vul hem op met behulp van ijzerdraad, watten en houtwol. Geef tot slot de Belg zijn houding; op een (schommelend) stokje schijnt het leukst te zijn.\342\200\231", chapter.pages[1].paragraphs.first.to_s
    end
  end
end
