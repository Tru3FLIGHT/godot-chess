class_name BoardState
extends RefCounted

var board := {}
var turn := "w"
var castling := "-"
var en_passant = null
var halfmove := 0
var fullmove := 1

func _init(data := {}) -> void:
	board = data.get("board", {})
	turn = data.get("turn", "w") 
	castling = data.get("castling", "-")
	en_passant = data.get("en_passant", null)
	halfmove = data.get("halfmove", 0)
	fullmove = data.get("fullmove", 1)

func has_piece(square: Vector2i) -> bool:
	return board.has(square)

func get_piece(square: Vector2i) -> Piece:
	return board.get(square)
