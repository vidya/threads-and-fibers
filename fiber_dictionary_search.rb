
require 'pry'

require './lib_dictionary_search'

class FiberWorker
  include LibDictionarySearch

  attr_accessor :fib, :let_list, :reversible_suffix_words,:letter_segment

  def initialize(let_list, letter_segment, reversible_suffix_words)
    @let_list = let_list
    @fib = Fiber.new {}
    @letter_segment = letter_segment
    @reversible_suffix_words = reversible_suffix_words
  end

  def continue_work
    #puts "89 let_list = #{let_list.inspect}"
    let = @let_list.pop
    @let_list = @let_list[0..-1]

    puts "76 let = #{let}"
    return nil if let.nil?

    rv_list = select_reversible_suffix_words delete_tiny_words(@letter_segment[let])

    rv_list.each { |rv| @reversible_suffix_words << rv }

    yield 9
  end
end

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
      #fiber_list = alphabet_list.inject({}) { |h, let| h[let] = fiber_create letter_segment[let]; h }
      #
      #fiber_list.each_value { |f| f.resume }

      fw1 = FiberWorker.new ('a'..'h').to_a, letter_segment, reversible_suffix_words
      fw2 = FiberWorker.new ('i'..'r').to_a, letter_segment, reversible_suffix_words
      fw3 = FiberWorker.new ('s'..'z').to_a, letter_segment, reversible_suffix_words

      while true
        #puts 'in loop'
        rv1 = fw1.continue_work {|x| x} #sleep 0.01}
        rv2 = fw2.continue_work { |x| x} #sleep 0.01}
        rv3 = fw3.continue_work {|x| x} #sleep 0.01}

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

  def fiber_create(list)
    Fiber.new do
      rv_list = select_reversible_suffix_words delete_tiny_words(list)

      rv_list.each { |rv| reversible_suffix_words << rv }
    end
  end
end
