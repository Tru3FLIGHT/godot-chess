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

static func on_board(square: Vector2i) -> bool:
	return Vector2i(0, 0) <= square and square <= Vector2i(7, 7)

# WARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNING
#			ALL GEN FUNCTIONS ASSUME VALID ORIGIN
#			allways validate origin before calling 
# WARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNINGWARNING


static func gen_knight_pseudo(state: BoardState, origin: Vector2i) -> Array:
	var moves := []
	for offset: Vector2i in KNIGHT_OFFSETS:
		var target := origin + offset
		if not on_board(target):
			continue
		
		if state.has_piece(target):
			if state.get_piece(target).get_color() == state.get_piece(origin).get_color():
				continue
		
		moves.append(target)

	return moves
