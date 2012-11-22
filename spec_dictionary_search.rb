require 'pry'

require 'minitest/autorun'
require 'minitest/spec'
require './dictionary_search'

describe DictionarySearch do
  attr_accessor :dict_search, :letter_segment

  before do
    @dict_search        = DictionarySearch.new('wordsEn.txt')

    dict_search.word_pairs
  end

  it 'selects_reversible_words' do
    rev_words_sample = []
    rev_words_sample << ['ahs', 'ash']
    rev_words_sample << ['alumin', 'alumni']
    rev_words_sample << ['sci', 'sic']
    rev_words_sample << ['nest', 'nets']
    rev_words_sample << ['waist', 'waits']

    assert_empty (rev_words_sample - dict_search.reversible_suffix_words)
  end
end
