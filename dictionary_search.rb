
require 'pry'

require './lib_dictionary_search'

class DictionarySearch
  include LibDictionarySearch

  attr_accessor :dict, :letter_segment, :alphabet_list, :reversible_suffix_words

  def initialize(file_path)
    @dict             = read_data file_path

    @alphabet_list    = ('a'..'z').to_a

    @letter_segment   = get_letter_segments

    @reversible_suffix_words = []
  end

  def word_pairs
    if reversible_suffix_words.empty?
      thread_list = alphabet_list.inject({}) { |h, let| h[let] = thread_start letter_segment[let]; h }

      thread_list.each_value { |thr| thread_value_append thr }
    end

    reversible_suffix_words
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

  def thread_start(list)
    Thread.start(list) { select_reversible_suffix_words delete_tiny_words(list) }
  end

  def thread_value_append(thr)
    thr.value.each { |rv| reversible_suffix_words << rv }
  end
end
