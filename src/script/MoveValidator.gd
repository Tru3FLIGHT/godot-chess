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
			return knight_shape_valid(state, origin, target)
		Piece.Ptype.KING:
			return king_move_valid(state, origin, target)
		Piece.Ptype.ROOK:
			return rook_shape_valid(state, origin, target)
		Piece.Ptype.BISHOP:
			return bishop_shape_valid(state, origin, target)
		Piece.Ptype.QUEEN:
			return queen_shape_valid(state, origin, target)
		Piece.Ptype.PAWN:
			return pawn_shape_valid(state, origin, target)

	return false

static func can_attack(state: BoardState, origin: Vector2i, target: Vector2i, verbose:= false) -> bool:
	var origin_piece := state.get_piece(origin)

	match origin_piece.get_type():
		Piece.Ptype.KNIGHT:
			return knight_shape_valid(state, origin, target)
		Piece.Ptype.KING:
			return king_shape_valid(state, origin, target)
		Piece.Ptype.ROOK:
			return rook_shape_valid(state, origin, target)
		Piece.Ptype.BISHOP:
			return bishop_shape_valid(state, origin, target)
		Piece.Ptype.QUEEN:
			return queen_shape_valid(state, origin, target)
		Piece.Ptype.PAWN:
			return pawn_attacks_square(state, origin, target)

	return false


static func get_valid_moves(state: BoardState, origin:Vector2i) -> Array:
	var valid_moves:= []
	for y in range(8):
		for x in range(8):
			print("evaluating: ", x, " ", y)
			if is_valid(state, origin, Vector2i(x,y)):
				print(x, " ", y, " is a valid position")
				valid_moves.append(Vector2i(x,y))

	return valid_moves

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

static func knight_shape_valid(_state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
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

static func king_shape_valid(_state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
	var delta := target - origin
	return delta in KING_OFFSETS

static func king_move_valid(state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
	if king_shape_valid(state, origin, target):
		var attacking_color := state.get_piece(origin).opposite_color()
		return not is_square_attacked(state, target, attacking_color)
	return false

static func is_square_attacked(state: BoardState, square: Vector2i, by_color: BoardState.Turn) -> bool:
	for occupied in state.get_occupied_squares():
		if state.get_piece(occupied).get_color() == by_color: #for every piece of attacking color
			if can_attack(state, occupied, square):
				print("Piece: ", occupied, " Attacks: ", square)
				return true
	return false

static func path_clear(state: BoardState, origin: Vector2i, target: Vector2i, direction: Vector2i) -> bool:
	var current := origin + direction

	while current != target:
		if state.has_piece(current):
			return false
		current += direction
	
	return true

static func rook_shape_valid(state: BoardState, origin: Vector2i, target:Vector2i) -> bool:
	var delta := target - origin

	if delta.x != 0 and delta.y !=0:
		return false

	var direction := Vector2i(sign(delta.x), sign(delta.y))

	return path_clear(state, origin, target, direction)

static func bishop_shape_valid(state: BoardState, origin: Vector2i, target:Vector2i) -> bool:
	var delta := target - origin

	if abs(delta.x) != abs(delta.y):
		return false
	
	var dierection := Vector2i(sign(delta.x), sign(delta.y))
	return path_clear(state, origin, target, dierection)

static func queen_shape_valid(state: BoardState, origin:Vector2i, target:Vector2i) -> bool:
	return rook_shape_valid(state, origin, target) or bishop_shape_valid(state, origin, target)

static func pawn_attacks_square(state: BoardState, origin:Vector2i, target:Vector2i) -> bool:
	var pawn := state.get_piece(origin)

	var dir := -1

	if pawn.get_color() == BoardState.Turn.BLACK:
		dir = 1
	
	var delta := target - origin
	return abs(delta.x) == 1 and delta.y == dir

static func pawn_shape_valid(state:BoardState, origin:Vector2i,target:Vector2i) -> bool:
	var pawn := state.get_piece(origin)
	var dir:= -1

	if pawn.get_color() == BoardState.Turn.BLACK:
		dir = 1

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