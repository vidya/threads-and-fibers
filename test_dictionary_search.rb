require 'pry'

require 'minitest/autorun'
require './dictionary_search'

class TestDictionarySearch < MiniTest::Unit::TestCase
  attr_accessor :dict_search

  def setup
    @dict_search = DictionarySearch.new('wordsEn.txt')
  end

  def test_that_dictionary_is_available
    dict = @dict_search.dict

    refute_empty dict, '--- error: dictionary is not available'
  end

  def test_that_dictionary_is_split_into_segments
    letter_segment_keys = dict_search.letter_segment.keys

    assert_equal letter_segment_keys, ('a'..'z').to_a, '--- error: unexpected letter segment keys'
  end
end

