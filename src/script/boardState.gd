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

func same_color_at(origin: Vector2i, target: Vector2i) -> bool:
	var orig_piece := get_piece(origin)
	var target_piece := get_piece(target)
	if orig_piece != null and target_piece != null:
		return orig_piece.get_color() == target_piece.get_color()
	return false

func attempt_move(origin: Vector2i, target: Vector2i) -> bool:
	print("attempting move: ", origin, " -> ", target)
	if MoveValidator.is_valid(self, origin, target):
		return move_piece(origin, target)
		
	return false

func whose_turn() -> Turn:
	return turn

func move_piece(origin: Vector2i, target: Vector2i) -> bool:
	if not has_piece(origin):
		return false

	var origin_piece: Piece = board.get(origin)
	board.erase(origin)
	board.set(target, origin_piece)
	return true
