class Peice:

	var type:		String
	var color:		String
	var fen:		String
	var has_moved:	bool

	func _init(ty: String, col: String, fe: String, moved:bool) -> void:
		type = ty
		color = col
		fen = fe
		has_moved = moved