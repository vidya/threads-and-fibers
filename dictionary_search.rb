
require 'pry'

class DictionarySearch
  attr_accessor :dict, :letter_segment, :word_count, :alphabet_list

  def initialize(file_path)
    @dict             = read_data file_path

    @alphabet_list    = ('a'..'z').to_a

    @letter_segment   = get_letter_segments
    @word_count       = {}
  end

  def word_pairs
  end

  def set_word_list_counts
    thread_list        = {}

    alphabet_list.each do |let|
      thread_list[let] = Thread.start(let) do
        word_count[let]   = letter_segment[let].size
      end
    end

    thread_list.each_value { |thr| thr.join}
  end

  #--- private
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
