
require 'pry'

require './lib_dictionary_search'

class DictionarySearch
  include LibDictionarySearch

  attr_accessor :dict, :letter_segment, :word_count, :alphabet_list, :reversible_suffix_words

  def initialize(file_path)
    @dict             = read_data file_path

    @alphabet_list    = ('a'..'z').to_a

    @letter_segment   = get_letter_segments
    @word_count       = {}

    @reversible_suffix_words = []
  end

  def word_pairs
    set_word_list_counts if reversible_suffix_words.empty?
    reversible_suffix_words
  end

  def set_word_list_counts
    thread_list        = {}

    alphabet_list.each do |let|
      thread_list[let]        = Thread.start(let) do

        letter_segment[let]   = delete_tiny_words letter_segment[let]
        word_count[let]       = letter_segment[let].size

        rev_words             = select_reversible_suffix_words letter_segment[let]

        rev_words.each { |rv| reversible_suffix_words << rv }
      end
    end

    thread_list.each_value { |thr| thr.join }
  end

  #--- private ------------------------------------------------------------------------------
  private
  def read_data(filename)
    File.readlines(filename).map { |ln| ln.chomp }
  end

  def get_letter_segments
    alphabet_list.inject({}) do |let_seg_hash, let|
      let_seg_hash[let] = dict.select { |word| word.start_with? let }

      let_seg_hash
    end
  end
end
