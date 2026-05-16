class_name MoveValidator
extends RefCounted

static func is_valid(state: BoardState, origin: Vector2i, target: Vector2i, _verbose := false) -> bool:
	if origin == target:
		return false

	if not state.has_piece(origin):
		return false

	if state.same_color_at(target, origin):
		return false

	var origin_piece := state.get_piece(origin)

	if state.whose_turn() != origin_piece.get_color():
		return false

	if target not in MoveGenerator.gen_pseudo_moves(state, origin):
		return false

	return move_keeps_king_safe(state, origin, target)

static func can_attack(state: BoardState, origin: Vector2i, target: Vector2i, _verbose := false) -> bool:
	var origin_piece := state.get_piece(origin)

	if origin_piece == null:
		return false

	if origin_piece.get_type() == Piece.Ptype.PAWN:
		return pawn_attacks_square(state, origin, target)

	return target in MoveGenerator.gen_pseudo_moves(state, origin)

static func get_valid_moves(state: BoardState, origin: Vector2i) -> Array:
	var valid_moves := []

	if not state.has_piece(origin):
		return valid_moves

	for target in MoveGenerator.gen_pseudo_moves(state, origin):
		if move_keeps_king_safe(state, origin, target):
			valid_moves.append(target)

	return valid_moves

static func is_square_attacked(state: BoardState, square: Vector2i, by_color: BoardState.Turn) -> bool:
	for occupied in state.get_occupied_squares():
		if state.get_piece(occupied).get_color() == by_color: # for every piece of attacking color
			if can_attack(state, occupied, square):
				return true
	return false

static func find_king(state: BoardState, color: BoardState.Turn) -> Vector2i:
	for square in state.get_occupied_squares():
		var piece := state.get_piece(square)

		if piece.get_color() == color and piece.get_type() == piece.Ptype.KING:
			return square
	
	return Vector2i(-1,-1)

static func move_keeps_king_safe(state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
	var moving_piece := state.get_piece(origin)
	var moving_color := moving_piece.get_color()
	var enemy_color := moving_piece.opposite_color()

	var test_state := state.copy()
	test_state.move_piece(origin, target)

	var king_square := find_king(test_state, moving_color)

	return not is_square_attacked(test_state,king_square,enemy_color)

static func pawn_attacks_square(state: BoardState, origin: Vector2i, target: Vector2i) -> bool:
	var pawn := state.get_piece(origin)

	var dir := -1

	if pawn.get_color() == BoardState.Turn.BLACK:
		dir = 1
	
	var delta := target - origin
	return abs(delta.x) == 1 and delta.y == dir