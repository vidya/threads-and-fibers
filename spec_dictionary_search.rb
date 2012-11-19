require 'pry'

require 'minitest/autorun'
require 'minitest/spec'
require './dictionary_search'

describe DictionarySearch do
  attr_accessor :dict_search, :letter_segment

  before do
    @dict_search        = DictionarySearch.new('wordsEn.txt')
    @letter_segment     = dict_search.letter_segment

    dict_search.set_word_list_counts
  end

  it 'provides_count_of_words_starting_with_each_alphabet' do
    word_count = dict_search.word_count

    word_count.keys.each do |let|
      assert_operator word_count[let], :>, 0, "--- error: word_count is not positive for letter: #{let}"
    end
  end

  it 'selects_reversible_words' do
    rev_words_sample = ['ash', 'anon', 'alumni', 'sic', 'sure', 'claps', 'prism', 'pool', 'posse', 'rose']
    assert_empty (rev_words_sample - dict_search.reversible_suffix_words)
  end
end
