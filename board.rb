class Board

  def initialize(words, space_char = "\u{2588}")
    @words = words
    @board = [@words.pop]
    @space = space_char
  end


  def width
    @board.first.length
  end

  def height
    @board.count
  end

  def add_down(w)
    length = w.length
    possible = []
    width.times do |a|
      (height + length - 1).times do |d|
        cross = false
        valid = length.times.inject(true) do |r, l|
          pos = 1 + (d - length) + l
          cross = cross || (pos >= 0 && @board[pos] && w[l] == @board[pos][a])
          test = (pos < 0 || @board[pos].nil? || @board[pos][a] == @space || @board[pos][a] == w[l])
          r & test
        end

        start = 1 + (d - length)
        bookend = (start - 1 < 0 || @board[start - 1][a] == @space) & (d + 1 >= height || @board[d + 1][a] == @space)
        possible << [start, a] if valid & cross & bookend
      end
    end

    pos = possible.shuffle.first
    if pos
      write_down(w, pos)
      true
    else
      false
    end
  end

  def add_across(w)
    length = w.length
    possible = []
    height.times do |d|
      (width + length - 1).times do |a|
        cross = false
        valid = length.times.inject(true) do |r, l|
          pos = 1 + (a - length) + l
          cross = cross || (pos >= 0 && w[l] == @board[d][pos])
          test = (pos < 0 || @board[d][pos].nil? || @board[d][pos] == @space || @board[d][pos] == w[l])
          r & test
        end

        start = 1 + (a - length)
        bookend = (start - 1 < 0 || @board[d][start - 1] == @space) & (a + 1 >= width || @board[d][a + 1] == @space)
        possible << [d, start] if valid & cross & bookend
      end
    end
    pos = possible.shuffle.first
    if pos
      write_across(w, pos)
      true
    else
      false
    end
  end

  def write_across(word, pos)
    dp, ap = pos
    length = word.length

    if ap < 0
      @board = @board.map do |row|
        row.rjust(ap.abs + width, @space)
      end
      ap = 0
    end

    ep = ap + length - 1
    if ep > width
      @board = @board.map do |row|
        row.ljust(ep + 1, @space)
      end
      ep = width - 1
    end

    @board[dp][ap..ep] = word
  end

  def write_down(word, pos)
    dp, ap = pos

    if dp < 0
      dp.abs.times do
        @board.unshift @space * width
      end
      dp = 0
    end

    word.chars.each_with_index do |char, i|
      @board.push @space * width if @board[dp + i].nil?
      @board[dp + i][ap] = char
    end
  end

  def generate(iter = 10)
    iter.times do
      @words = @words.shuffle
      w = @words.pop
      coin = (rand.round == 0 ? :heads : :tails)

      if coin == :heads
        add_down(w) || add_across(w) || @words.push(w)
      else
        add_across(w) || add_down(w) || @words.push(w)
      end

      break if @words.first.nil?
    end
  end


  def print
    @board.each do |row|
      puts row.upcase
    end
    puts ""
    puts "=" * width
    puts ""
  end
end
