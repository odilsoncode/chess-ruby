require_relative 'piece'
require_relative '../chessboard'
require_relative 'findable'
class Bishop < Piece
    attr_reader  :attack_moves, :allowed_moves
    include Findable

    def initialize(position, color, the_chessboard = ChessBoard.new)
        super(position, color)
        @attack_moves = []
        @allowed_moves = find_both_diagonal_and_perpandicular_moves(the_chessboard)
    end

end