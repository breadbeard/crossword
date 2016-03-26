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

  def add_down(words, board, word = nil, pos = nil)
    word ||= words.shuffle.pop
    length = word.length
    possible = []

    _pos = if pos
      row, col = pos
      start = 1 + (row - length)
      possible_down(start, length, word, board, row, col)
    else
      width.times do |col|
        (height + length - 1).times do |row|
          start = 1 + (row - length)
          possible << possible_down(start, length, word, board, row, col)
        end
      end
      possible.compact.shuffle.first
    end

    if _pos
      write_down(word, board, _pos[:pos])
      look_down_around(word, words, board, _pos[:pos], _pos[:cross])
    else
      false
    end
  end

  def possible_down(start, length, word, board, row, col)
    cross = []
    valid = length.times.inject(true) do |r, l|
      pos = 1 + (row - length) + l
      char = square(board, pos, col)
      cross << [pos, col] if char == word[l]
      test = (!char || char == word[l])
      r & test
    end

    bookend = (!square(board, start - 1, col) && !square(board, row + 1, col))
    valid && cross.first && bookend ? {pos: [start, col], cross: cross } : nil
  end

  def add_across(words, board, word = nil, pos = nil)
    word ||= words.shuffle.pop
    length = word.length
    possible = []

    _pos = if pos
      row, col = pos
      start = 1 + (col - length)
      possible_across(start, length, word, board, row, col)
    else
      height.times do |row|
        (width + length - 1).times do |col|
          start = 1 + (col - length)
          possible << possible_across(start, length, word, board, row, col)
        end
      end
      possible.compact.shuffle.first
    end

    if _pos
      write_across(word, board, _pos[:pos])
      look_across_around(word, words, board, _pos[:pos], _pos[:cross])
    else
      false
    end
  end

  def possible_across(start, length, word, board, row, col)
    cross = []
    valid = length.times.inject(true) do |r, l|
      pos = 1 + (col - length) + l
      cross << [row, pos] if (pos >= 0 && word[l] == board[row][pos])
      test = (pos < 0 || !square(board, row, pos) || board[row][pos] == word[l])
      r & test
    end

    bookend = (!square(board, row, start - 1) && !square(board, row, col + 1))
    valid && cross.first && bookend ? {pos: [row, start], cross: cross} : nil
  end

  def look_down_around(word, words, board, pos, cross)
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
          left << lchar if lchar
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
          result = false
          words.each_with_index do |w, wi|
            if si = w.index(subword)
              w_pos = [row + ci, col - (si + left.length)]
              dup_words = words.dup
              dup_words.delete_at(wi)
              break if result = add_across(dup_words, board, w, w_pos)
            end
          end
          return result
        end
      end
    end
    valid ? [words, board] : false
  end

  def look_across_around(word, words, board, pos, cross)
    valid = true
    if words.first
      row, col = pos
      word.chars.each_with_index do |c, ci|
        cur_pos = [row, col + ci]
        next if cross.include? cur_pos

        top_row = row
        top = ""
        loop do
          top_row -= 1
          tchar = square(board, top_row, col + ci)
          top << tchar if tchar
          break unless tchar
        end

        bottom_row = row
        bottom = ""
        loop do
          bottom_row += 1
          bchar = square(board, bottom_row, col + ci)
          bottom << bchar if bchar
          break unless bchar
        end

        if top || bottom
          subword = [top, c, bottom].compact.join('')
          result = false
          words.each_with_index do |w, wi|
            if si = w.index(subword)
              w_pos = [row - (si + top.length), col + ci]
              dup_words = words.dup
              dup_words.delete_at(wi)
              break if result = add_down(dup_words, board, w, w_pos)
            end
          end
          return result
        end
      end
    end

    valid ? [words, board] : false
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
      if result = (rand.round == 0 ? add_down(@words, @board) : add_across(@words, @board))
        @words, @board = result
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
