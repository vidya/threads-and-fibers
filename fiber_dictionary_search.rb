
require 'pry'

require './lib_dictionary_search'

class FiberDictionarySearch
  include LibDictionarySearch

  attr_accessor :dict, :letter_segment, :word_count, :alphabet_list, :reversible_suffix_words

  def initialize(file_path)
    @dict             = read_data file_path

    @alphabet_list    = ('a'..'z').to_a

    @letter_segment   = get_letter_segments

    @word_count = @letter_segment.inject({}) { |wc_hash, (k, v)| wc_hash[k] = v.size; wc_hash }

    @reversible_suffix_words = []
  end

  def word_pairs
    if reversible_suffix_words.empty?
      fiber_list = alphabet_list.inject({}) { |h, let| h[let] = fiber_create letter_segment[let]; h }

      fiber_list.each_value { |thr| fiber_value_append thr }
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

  def fiber_create(list)
    Fiber.new { Fiber.yield(select_reversible_suffix_words delete_tiny_words(list)) }
  end

  def fiber_value_append(fiber)
    fiber.resume.each { |rv| reversible_suffix_words << rv }
  end
end
