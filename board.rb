class Board

  def initialize(words, space_char = "\u{2588}", board = nil)
    @words = words
    @board = board || [@words.pop]
    @space = space_char
  end


  def width
    @board.first.length
  end

  def height
    @board.count
  end

  def add_down(word, board, words, pos = nil)
    length = word.length
    possible = []
    width.times do |col|
      (height + length - 1).times do |row|
        cross = []
        valid = length.times.inject(true) do |r, l|
          pos = 1 + (row - length) + l
          cross << [pos, col] if (pos >= 0 && board[pos] && word[l] == board[pos][col])
          test = (pos < 0 || board[pos].nil? || board[pos][col] == @space || board[pos][col] == word[l])
          r & test
        end

        start = 1 + (row - length)
        bookend = (start - 1 < 0 || board[start - 1][col] == @space) & (row + 1 >= height || board[row + 1][col] == @space)
        possible << {pos: [start, col], cross: cross } if valid & cross.first & bookend
      end
    end

    position = possible.shuffle.detect do |_pos|
      look_down_around(word, board, words, _pos[:pos], _pos[:cross])
    end

    position ? write_down(word, board, position[:pos]) : false
  end

  def add_across(word, board, words, pos = nil)
    length = word.length
    possible = []
    height.times do |row|
      (width + length - 1).times do |col|
        cross = []
        valid = length.times.inject(true) do |r, l|
          pos = 1 + (col - length) + l
          cross << [row, pos] if (pos >= 0 && word[l] == board[row][pos])
          test = (pos < 0 || board[row][pos].nil? || board[row][pos] == @space || board[row][pos] == word[l])
          r & test
        end

        start = 1 + (col - length)
        bookend = (start - 1 < 0 || board[row][start - 1] == @space) & (col + 1 >= width || board[row][col + 1] == @space)
        possible << {pos: [row, start], cross: cross} if valid & cross.first & bookend
      end
    end

    position = possible.shuffle.detect do |_pos|
      look_across_around(word, board, words, _pos[:pos], _pos[:cross])
    end

    position ? write_across(word, board, position[:pos]) : false
  end

  def look_down_around(word, board, words, pos, cross)
    valid = true
    if words.first
      dp, ap = pos
      word.chars.each_with_index do |c, i|
        cur_pos = [dp + i, ap]
        next if cross.include? cur_pos
        #left = (board[dp + i] & board[dp + i][ap - 1]) ? board[dp + i][ap - 1] : nil
        #right = (board[dp + i] & board[dp + i][ap - 1]) ? board[dp + i][ap + 1] : nil

        #if left || right
        #  subword = [left, c, right]
        #  pos_words = words.select {|w| w.include?(subword)}
        #end
      end
    end

    valid
  end

  def look_across_around(word, board, words, pos, cross)
    valid = true
    if words.first
      dp, ap = pos
      word.chars.each_with_index do |c, i|
        cur_pos = [dp, ap + i]
        next if cross.include? cur_pos

      end
    end

    valid
  end


  def write_across(word, board, pos)
    dp, ap = pos
    length = word.length

    if ap < 0
      board = board.map do |row|
        row.rjust(ap.abs + width, @space)
      end
      ap = 0
    end

    ep = ap + length - 1
    if ep > width
      board = board.map do |row|
        row.ljust(ep + 1, @space)
      end
      ep = width - 1
    end

    board[dp][ap..ep] = word

    board
  end

  def write_down(word, board, pos)
    dp, ap = pos

    if dp < 0
      dp.abs.times do
        board.unshift @space * width
      end
      dp = 0
    end

    word.chars.each_with_index do |char, i|
      board.push @space * width if board[dp + i].nil?
      board[dp + i][ap] = char
    end

    board
  end

  def generate(iter = 10)
    iter.times do
      @words = @words.shuffle
      w = @words.pop
      coin = (rand.round == 0 ? :heads : :tails)

      if coin == :heads
        b = add_down(w, @board, @words) || add_across(w, @board, @words)
        b ? @board = b : @words.push(w)
      else
        b = add_across(w, @board, @words) || add_down(w, @board, @words)
        b ? @board = b : @words.push(w)
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
