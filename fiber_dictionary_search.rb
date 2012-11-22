
require 'pry'
require 'fiber'

require './lib_dictionary_search'

class FiberDictionarySearch
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
      fw1 = create_fiber
      fw2 = create_fiber
      fw3 = create_fiber

      list1 = ('a'..'h').to_a
      list2 = ('i'..'r').to_a
      list3 = ('s'..'z').to_a

      while true
        list1, rv1 = fw1.resume(list1) if fw1.alive?
        list2, rv2 = fw2.resume(list2) if fw2.alive?
        list3, rv3 = fw3.resume(list3) if fw3.alive?

        append_rv_list rv1 unless rv1.nil?
        append_rv_list rv2 unless rv2.nil?
        append_rv_list rv3 unless rv3.nil?

        break unless (rv1 || rv2 || rv3)
      end
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

  def append_rv_list(rv_list)
    rv_list.each { |rv| reversible_suffix_words << rv }
  end

  def create_fiber
    Fiber.new do |list|
      until list.empty?
        let = list.pop
        puts "let = #{let}"

        Fiber.yield list[0..-1], select_reversible_suffix_words(delete_tiny_words @letter_segment[let])
      end
    end
  end
end
