class_name MoveValidator
extends RefCounted

static func is_valid(state: BoardState, from: Vector2i, to: Vector2i) -> bool:
    if from == to:
        push_error("Position error: cannot move to the same space")
        return false

    if not state.has_piece(from):
        push_error("Position error: no piece located at: ", from)
        return false
    
    var moving := state.get_piece(from)
    

    if state.same_color_at(to, moving):
        push_error("Illigal move: cannot move onto your own piece")
        return false

    if state.whose_turn() != moving.get_color():
        push_error("Illigal move: it is not that player's turn")
        return false

    match moving.get_type():
        Piece.Ptype.PAWN:
            return pawn_move_valid(state, from, to)

    return true


static func pawn_move_valid(state: BoardState, from: Vector2i, to: Vector2i) -> bool:
    return true