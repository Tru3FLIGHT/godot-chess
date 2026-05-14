class_name Piece
extends RefCounted

var type :      String
var color:      String
var fen_char:   String
var has_moved:= false

func _init(data : Dictionary) -> void:
    type = data.get("type", "pawn")
    color= data.get("color", "white")
    fen_char = data.get("fen", "P")
    has_moved = data.get("has_moved", false)

