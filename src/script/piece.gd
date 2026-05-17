class_name Piece
extends RefCounted

var type :Ptype
var color:BoardState.Turn
var fen_char: String
var has_moved:= false
var moves := []

enum Ptype {
	PAWN,
	KNIGHT,
	BISHOP,
	ROOK,
	QUEEN,
	KING
}

func _init(data : Dictionary) -> void:
	type = data.get("type", Ptype.PAWN)
	color= data.get("color", BoardState.Turn.WHITE)
	fen_char = data.get("fen", "P")
	has_moved = data.get("has_moved", false)

func moved() -> bool:
	return has_moved

func get_type() -> Ptype:
	return type

func get_color() -> BoardState.Turn:
	return color
	
func opposite_color() -> BoardState.Turn:
	if color == BoardState.Turn.WHITE:
		return BoardState.Turn.BLACK
	return BoardState.Turn.WHITE

func get_moves() -> Array:
	return moves

func clear_moves():
	moves = []

func set_moves(new: Array):
	moves = new

func copy() -> Piece:
	return Piece.new({
		"type": type,
		"color": color,
		"fen":fen_char,
		"has_moved":has_moved
	})