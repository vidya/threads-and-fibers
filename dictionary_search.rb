
require 'pry'

class DictionarySearch
  attr_accessor :dict, :letter_segment

  def initialize(file_path)
    @dict             = read_data file_path
    @letter_segment   = get_letter_segments
    #binding.pry
  end

  def word_pairs
  end

  #--- private
  private
  def read_data(filename)
    File.readlines(filename).map { |ln| ln.chomp }
  end

  def get_letter_segments
    ('a'..'z').inject({}) do |let_seg_hash, let|
      let_seg_hash[let] = dict.select { |word| word.start_with? let }

      let_seg_hash
    end
  end
end
