require_relative 'words'
require_relative 'board'

words = Words.list
board = Board.new(Words.list, '_')
board.generate(10)
board.print



def test
  board = ["_W____",
           "_H____",
           "SILVER",
           "_P____"]

  board = write_across("crow",[0,-2],board)
  print_board(board)
end
