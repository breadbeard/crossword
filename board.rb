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

  def square(board, row, col)
    if row >= 0 && col >= 0 && board[row] && board[row][col] && board[row][col] != @space
      board[row][col]
    else
      false
    end
  end

  def add_down(word, board, words, pos = nil)
    length = word.length
    possible = []
    width.times do |col|
      (height + length - 1).times do |row|
        cross = []
        valid = length.times.inject(true) do |r, l|
          pos = 1 + (row - length) + l
          char = square(board, pos, col)
          cross << [pos, col] if char == word[l]
          test = (!char || char == word[l])
          r & test
        end

        start = 1 + (row - length)
        bookend = (!square(board, start - 1, col) && !square(board, row + 1, col))
        possible << {pos: [start, col], cross: cross } if (valid && cross.first && bookend)
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
          test = (pos < 0 || !square(board, row, pos) || board[row][pos] == word[l])
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
      row, col = pos
      word.chars.each_with_index do |c, ci|
        cur_pos = [row + ci, col]
        next if cross.include? cur_pos

        left_col = col
        left = ""
        loop do
          left_col -= 1
          lchar = square(board, row + ci, left_col)
          left << lchar if lchar && lchar != @space
          break unless lchar
        end

        right_col = col
        right = ""
        loop do
          right_col += 1
          rchar = square(board, row + ci, right_col)
          right << rchar if rchar
          break unless rchar
        end

        if left || right
          subword = [left, c, right].compact.join('')
          words.each_with_index do |w, wi|
            if si = w.index(subword)
              w_pos = [row + ci, col - (si + left.length)]
              d_words = words.dup
              d_words.delete_at(wi)
              add_across(w, board, d_words, w_pos)
              # got to here last
            end
          end
        end
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
