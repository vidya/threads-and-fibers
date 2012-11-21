
require 'pry'
require 'fiber'

require './lib_dictionary_search'

#class FiberWorker #< Fiber
#  include LibDictionarySearch
#
#  attr_accessor :fib, :let_list,:letter_segment
#
#  def initialize(let_list, letter_segment)
#    @let_list = let_list
#    #@fib = Fiber.new {}
#    @letter_segment = letter_segment
#
#    #binding.pry
#    @fib = Fiber.new do
#      return nil if @let_list.empty?
#
#      let, @let_list = @let_list.pop, @let_list[0..-1]
#      puts "let = #{let}"
#
#      #yield
#      yield select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
#    end
#  end
#
#  def continue_work(&block)
#    @fib ||= Fiber.new do
#      return nil if @let_list.empty?
#
#      let, @let_list = @let_list.pop, @let_list[0..-1]
#      puts "let = #{let}"
#
#      yield  select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
#    end
#
#    @fib.resume(&block)
#  end
#
#  #def continue_work
#  #  return nil if @let_list.empty?
#  #
#  #  let, @let_list = @let_list.pop, @let_list[0..-1]
#  #
#  #  yield  select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
#  #end
#end

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

      list1 = ('a'..'h').to_a
      fw1 = Fiber.new do
        while not list1.empty?
          let, list1 = list1.pop, list1[0..-1]
          puts "let = #{let}"

          Fiber.yield select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
        end
      end

      list2 = ('i'..'r').to_a
      fw2 = Fiber.new do
        while not list2.empty?

         let, list2 = list2.pop, list2[0..-1]
          puts "let = #{let}"

          Fiber.yield select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
        end

      end

      list3 = ('s'..'z').to_a
      fw3 = Fiber.new do
        while not list3.empty?

          let, list3 = list3.pop, list3[0..-1]
          puts "let = #{let}"

          Fiber.yield select_reversible_suffix_words delete_tiny_words(@letter_segment[let])
        end
      end

      while true
        rv1 = fw1.resume(rv1) if fw1.alive?
        rv2 = fw2.resume(rv2) if fw2.alive?
        rv3 = fw3.resume(rv3) if fw3.alive?

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
end
