require_relative 'setup'

require_relative 'chessboard'

chessboard = ChessBoard.new

setup(chessboard)
chessboard.active_piece = chessboard.data.dig(1, 3)
p chessboard.data.dig(1, 3).attack_moves
p chessboard.data.dig(1, 3).allowed_moves
chessboard.display_chess_board