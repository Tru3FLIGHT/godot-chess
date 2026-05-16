class_name MoveGenerator
extends RefCounted


const KNIGHT_OFFSETS := [
	Vector2i(2, 1),
	Vector2i(2, -1),
	Vector2i(-2, 1),
	Vector2i(-2, -1),
	Vector2i(1, -2),
	Vector2i(-1, -2),
	Vector2i(1, 2),
	Vector2i(-1, 2)
]
const KING_OFFSETS := [
	Vector2i(1, 1),
	Vector2i(-1, -1),
	Vector2i(-1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

const ROOK_DIRECTIONS := [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]
const BISHOP_DIRECTIONS := [
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, -1),
	Vector2i(-1, 1)
]

static func on_board(square: Vector2i) -> bool:
	return 0 <= square.x and 0 <= square.y and square.y <= 7 and square.x <= 7

#functional equivilant of MoveValidator.path_clear()
static func traverse_path(state: BoardState, origin: Vector2i, direction: Vector2i) -> Array:
	var current := origin + direction
	var spaces := []

	while on_board(current):
		if state.has_piece(current):
			if not state.same_color_at(origin, current):
				spaces.append(current)
			break

		spaces.append(current)
		current += direction
	
	return spaces


# WARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNING
#			ALL GEN FUNCTIONS ASSUME VALID ORIGIN
#			allways validate origin before calling 
# WARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNING

static func gen_offset_pseudo(state: BoardState, origin: Vector2i, offset_arr: Array) -> Array:
	var moves := []
	for offset: Vector2i in offset_arr:
		var target := origin + offset
		if not on_board(target):
			continue
		
		if state.has_piece(target) and state.same_color_at(origin, target):
				continue
		
		moves.append(target)

	return moves

static func gen_knight_pseudo(state: BoardState, origin: Vector2i) -> Array:
	return gen_offset_pseudo(state, origin, KNIGHT_OFFSETS)

static func gen_king_pseudo(state: BoardState, origin: Vector2i) -> Array:
	return gen_offset_pseudo(state, origin, KING_OFFSETS)

static func gen_directional_pseudo(state: BoardState, origin: Vector2i, dirs: Array) -> Array:
	var moves := []
	for direction: Vector2i in dirs:
		var dir_moves := traverse_path(state, origin, direction)
		moves.append_array(dir_moves)
	
	return moves

static func gen_rook_pseudo(state: BoardState, origin: Vector2i) -> Array:
	return gen_directional_pseudo(state, origin, ROOK_DIRECTIONS)

static func gen_bishop_pseudo(state: BoardState, origin: Vector2i) -> Array:
	return gen_directional_pseudo(state, origin, BISHOP_DIRECTIONS)

static func gen_queen_pseudo(state: BoardState, origin: Vector2i) -> Array:
	var moves := gen_rook_pseudo(state, origin)
	var b_moves := gen_bishop_pseudo(state, origin)
	moves.append_array(b_moves)

	return moves

static func gen_pawn_pseudo(state: BoardState, origin: Vector2i) -> Array:
	var moves := []
	var movement_dir := -1
	var starting_rank := 6
	var pawn := state.get_piece(origin)

	if pawn.get_color() == BoardState.Turn.BLACK:
		movement_dir = 1
		starting_rank = 1

	var move_one := origin + Vector2i(0, movement_dir)
	if on_board(move_one) and not state.has_piece(move_one):
		moves.append(move_one)

		if origin.y == starting_rank:

			var move_two := origin + Vector2i(0, 2*movement_dir)
			if on_board(move_two) and not state.has_piece(move_two):

				moves.append(move_two)

	var capture_offsets := [
	Vector2i(-1, movement_dir),
	Vector2i(1, movement_dir),
	]

	for offset : Vector2i in capture_offsets:
		var target := origin + offset
		if pawn_capture(state, target, pawn):
			moves.append(target)

		if on_board(target) and state.en_passant == target and not state.has_piece(target):
			moves.append(target)
	
	return moves

static func pawn_capture(state: BoardState, target: Vector2i, pawn: Piece) -> bool:
	if on_board(target):
		if state.has_piece(target):
			return state.get_piece(target).get_color() != pawn.get_color()
	return false
			
static func gen_pseudo_moves(state: BoardState, origin: Vector2i) -> Array:
	var piece := state.get_piece(origin)

	match piece.get_type():
		Piece.Ptype.KNIGHT:
			return gen_knight_pseudo(state, origin)
		Piece.Ptype.KING:
			return gen_king_pseudo(state, origin)
		Piece.Ptype.ROOK:
			return gen_rook_pseudo(state, origin)
		Piece.Ptype.BISHOP:
			return gen_bishop_pseudo(state, origin)
		Piece.Ptype.QUEEN:
			return gen_queen_pseudo(state, origin)
		Piece.Ptype.PAWN:
			return gen_pawn_pseudo(state, origin)

	return []