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

func same_color_at(square: Vector2i, piece: Piece) -> bool:
	var target := get_piece(square)
	if target != null:
		return target.get_color() == piece.get_color()
	return false

func attempt_move(from: Vector2i, to: Vector2i) -> bool:
	print("attempting move: ", from, " -> ", to)
	if MoveValidator.is_valid(self, from, to):
		return move_piece(from, to)
		
	return false

func whose_turn() -> Turn:
	return turn

func move_piece(from: Vector2i, to: Vector2i) -> bool:
	if not has_piece(from):
		return false


	var mover: Piece = board.get(from)
	board.erase(from)
	board.set(to, mover)
	return true
