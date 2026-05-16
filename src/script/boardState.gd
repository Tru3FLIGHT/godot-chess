class_name BoardState
extends RefCounted

var board := {}
var turn: Turn = Turn.WHITE
var castling := "-"
var en_passant = null
var halfmove := 0
var fullmove := 1

enum Turn {
	WHITE,
	BLACK
}

func turn_to_string() -> String:
	if turn == Turn.WHITE:
		return "White"
	return "Black"

func opposite_turn(a: Turn) -> Turn:
	return Turn.BLACK if a == Turn.WHITE else Turn.WHITE

func _init(data := {}) -> void:
	board = data.get("board", {})
	turn = data.get("turn", Turn.WHITE) 
	castling = data.get("castling", "-")
	en_passant = data.get("en_passant", null)
	halfmove = data.get("halfmove", 0)
	fullmove = data.get("fullmove", 1)

func has_piece(square: Vector2i) -> bool:
	return board.has(square)

func get_piece(square: Vector2i) -> Piece:
	return board.get(square)

func get_occupied_squares() -> Array:
	return board.keys()

func is_in_check(color: Turn) -> bool:
	var king := MoveValidator.find_king(self, color)

	if MoveValidator.is_square_attacked(self, king, opposite_turn(color)):
		return true
	else:
		return false

func get_color(color : Turn) -> Array:
	var pieces := []
	var squares := get_occupied_squares()
	for square in squares:
		if get_piece(square).get_color() == color:
			pieces.append(square)

	return pieces

func same_color_at(origin: Vector2i, target: Vector2i) -> bool:
	var orig_piece := get_piece(origin)
	var target_piece := get_piece(target)
	if orig_piece != null and target_piece != null:
		return orig_piece.get_color() == target_piece.get_color()
	return false

func attempt_move(origin: Vector2i, target: Vector2i) -> bool:
	
	if target in get_piece(origin).get_moves():
		if not move_piece(origin, target):
			return false
		end_turn()
		return true
	return false

func whose_turn() -> Turn:
	return turn

func end_turn():
	for square in get_occupied_squares():
		get_piece(square).clear_moves()

	turn = opposite_turn(turn)
	print(turn_to_string(),"'s turn")

func move_piece(origin: Vector2i, target: Vector2i) -> bool:
	if not has_piece(origin):
		return false

	var origin_piece: Piece = get_piece(origin)
	var was_en_passant := is_en_passant_capture(origin, target)

	board.erase(origin)

	if was_en_passant:
		var captured_pawn_square := Vector2i(target.x, origin.y)
		board.erase(captured_pawn_square)

	board.set(target, origin_piece)
	origin_piece.has_moved = true

	en_passant = null

	if is_pawn_double_move_for(origin_piece, origin, target):
		en_passant = get_en_passant_target(origin, target)

	return true

func is_pawn_double_move_for(piece: Piece, origin: Vector2i, target: Vector2i) -> bool:
	if piece.get_type() != Piece.Ptype.PAWN:
		return false
	
	return abs(target.y - origin.y) == 2

#assumes a double moved happened
func get_en_passant_target(origin: Vector2i, target: Vector2i) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(origin.x, (origin.y + target.y) / 2)

func is_en_passant_capture(origin: Vector2i, target: Vector2i) -> bool:
	var piece := get_piece(origin)
	if piece == null:
		return false
	
	if piece.get_type() != Piece.Ptype.PAWN:
		return false
	
	if en_passant == null:
		return false
	
	if target != en_passant:
		return false
	
	if has_piece(target):
		return false
	
	return abs(target.x - origin.x) == 1

func copy() -> BoardState:
	var coppied_board := {}

	for square in board.keys():
		coppied_board[square] = board[square].copy()

	return BoardState.new({
		"board": coppied_board,
		"turn":turn,
		"castling":castling,
		"en_passant":en_passant,
		"halfmove":halfmove,
		"fullmove":fullmove
	})

#func _notification(what: int) -> void:
#	if (what == NOTIFICATION_PREDELETE):
#		print("freeing BoardState")