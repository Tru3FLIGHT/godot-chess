class_name FenParser
extends RefCounted

static func char_to_piece(fen_char: String) -> Dictionary:
	var color := "white" if fen_char == fen_char.to_upper() else "black"
	var lower := fen_char.to_lower()

	var type := ""
	match lower:
		"p": type = "pawn"
		"n": type = "knight"	
		"b": type = "bishop"
		"r": type = "rook"
		"q": type = "queen"
		"k": type = "king"
		_: return {}

	return {			
		"type":type,
		"color":color,
		"fen":fen_char,
		"has_moved": false
		}

static func parse_board(fen: String) -> Dictionary:
	var board := {}
	var ranks := fen.split("/")

	#there will be 8 ranks
	if len(ranks) != 8:
		push_error("Invalid FEN: Incorrect Number of ranks")
		return {}

	for y in range(8):
		var x := 0
		var rank := ranks[y]

		for i in range(len(rank)):
			var character := rank.substr(i, 1)

			if character in "12345678":
				x += int(character)
			else:
				var peice := char_to_piece(character)

				if peice.is_empty():
					push_error("Error Parsing Peice: ", character)
					return {}
				if x >= 8:
					push_error("Incorrect FEN: rank too wide")
					return {}
				
				board[Vector2i(x,y)] = peice
				x += 1
		
		#rank does not account for all 8 places
		if x != 8:
			push_error("Incorrect FEN: rank incomplete")
			return {}
		
	return board

static func parse(fen: String) -> Dictionary:
	var parts := fen.strip_edges().split(" ")

	if parts.size() != 6:
		push_error("Invalid FEN: expected 6 fields")
		return {}

	var board := parse_board(parts[0])
	if board.is_empty():
		push_error("Invalid FEN board")
		return {}

	return {
		"board": board,
		"turn": parts[1],
		"castling": parts[2],
		"en_passant": algebraic_to_board(parts[3]),
		"halfmove": int(parts[4]),
		"fullmove": int(parts[5])
	}

static func algebraic_to_board(square: String) -> Variant:
	if square == "-":
		return null

	if square.length() != 2:
		return null

	var file := square.substr(0, 1)
	var rank := square.substr(1, 1)

	var files := "abcdefgh"
	var x := files.find(file)
	var rank_num := int(rank)

	if x == -1 or rank_num < 1 or rank_num > 8:
		return null

	var y := 8 - rank_num
	return Vector2i(x, y)