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
    
    if state.same_color_at(target, origin):
        if verbose:
            push_error("Illigal move: cannot move onto your own piece")
        return false

    var origin_piece := state.get_piece(origin)

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
            return rook_move_valid(state, origin, target)
        Piece.Ptype.BISHOP:
            return bishop_move_valid(state, origin, target)
        Piece.Ptype.QUEEN:
            return queen_move_valid(state, origin, target)
        Piece.Ptype.PAWN:
            return pawn_move_valid(state, origin, target)

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

static func path_clear(state: BoardState, origin: Vector2i, target: Vector2i, direction: Vector2i) -> bool:
    var current := origin + direction

    while current != target:
        if state.has_piece(current):
            return false
        current += direction
    
    return true

static func rook_move_valid(state: BoardState, origin: Vector2i, target:Vector2i) -> bool:
    var delta := target - origin

    if delta.x != 0 and delta.y !=0:
        return false

    var direction := Vector2i(sign(delta.x), sign(delta.y))

    return path_clear(state, origin, target, direction)

static func bishop_move_valid(state: BoardState, origin: Vector2i, target:Vector2i) -> bool:
    var delta := target - origin

    if abs(delta.x) != abs(delta.y):
        return false
    
    var dierection := Vector2i(sign(delta.x), sign(delta.y))
    return path_clear(state, origin, target, dierection)

static func queen_move_valid(state: BoardState, origin:Vector2i, target:Vector2i) -> bool:
    return rook_move_valid(state, origin, target) or bishop_move_valid(state, origin, target)

static func pawn_move_valid(state:BoardState, origin:Vector2i,target:Vector2i) -> bool:
    var pawn := state.get_piece(origin)
    var white_dir = -1
    var black_dir = 1
    var dir: int

    if pawn.get_color() == BoardState.Turn.WHITE:
        dir = white_dir
    else:
        dir = black_dir

    var delta := target - origin

    if delta == Vector2i(0,dir):
        return not state.has_piece(target)

    if not pawn.has_moved and delta == Vector2i(0,dir*2):
        #is there a blocker inbetween?
        var middle := origin + Vector2i(0,dir)
        return not state.has_piece(target) and not state.has_piece(middle)

    if abs(delta.x) == 1 and delta.y == dir:
        return state.has_piece(target)
    
    return false