class_name MoveValidator
extends RefCounted

static func is_valid(state: BoardState, origin: Vector2i, target: Vector2i, verbose:= false) -> bool:
    if origin == target:
        if verbose:
            push_error("Position error: cannot move target the same space")
        return false

    if not state.has_piece(origin):
        if verbose:
            push_error("Position error: no piece located at: ", origin)
        return false
    
    var origin_piece := state.get_piece(origin)
    

    if state.same_color_at(target, origin):
        if verbose:
            push_error("Illigal move: cannot move onto your own piece")
        return false

    if state.whose_turn() != origin_piece.get_color():
        if verbose:
            push_error("Illigal move: it is not that player's turn")
        return false

    match origin_piece.get_type():
        Piece.Ptype.KNIGHT:
            return knight_move_valid(state, origin, target)
        Piece.Ptype.KING:
            return king_move_valid(state, origin, target)
        Piece.Ptype.ROOK:
            return true
        Piece.Ptype.BISHOP:
            return true
        Piece.Ptype.QUEEN:
            return true
        Piece.Ptype.PAWN:
            return true

    return false

const KNIGHT_OFFSETS := [
    Vector2i(2,1),
    Vector2i(2,-1),
    Vector2i(-2,1),
    Vector2i(-2,-1),
    Vector2i(1,-2),
    Vector2i(-1,-2),
    Vector2i(1,2),
    Vector2i(-1,2)
]

static func knight_move_valid(_state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
    var delta := target - origin
    return delta in KNIGHT_OFFSETS

const KING_OFFSETS := [
    Vector2i(1,1),
    Vector2i(-1,-1),
    Vector2i(-1,1),
    Vector2i(1,-1),
    Vector2i(-1,0),
    Vector2i(1,0),
    Vector2i(0,1),
    Vector2i(0,-1)
]

static func king_move_valid(_state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
    var delta := target - origin
    return delta in KING_OFFSETS