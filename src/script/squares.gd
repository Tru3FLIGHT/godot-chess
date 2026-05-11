extends Node2D


const BOARD_SIZE := 8
const TILE_SIZE := 64

const STARTING_STATE := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

@export
var color_primary: Color
@export
var color_secondary: Color

@onready var highlight: ColorRect = $squares/highlight
var last_board_pos := Vector2i(-1,-1)

const PIECE_W := 161
const PIECE_H := 155

const ATLAS := preload("res://clipart4559543.png")

const PIECES := {
	"king":0,
	"queen":1,
	"bishop":2,
	"knight":3,
	"rook":4,
	"pawn":5,
	"white":0,
	"black":1
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	make_board()
	highlight.move_to_front()
	highlight.size = Vector2(TILE_SIZE,TILE_SIZE)
	highlight.position = board_to_world(last_board_pos)
	highlight.hide()


func board_to_world(square: Vector2i) -> Vector2:
	return Vector2(square.x * TILE_SIZE, square.y * TILE_SIZE)

func world_to_board(coord: Vector2) -> Vector2i:
	var board := Vector2i(floor(coord.x/TILE_SIZE), floor(coord.y / TILE_SIZE))
	if board_valid(board.x) and board_valid(board.y):
		return board
	else: 
		return Vector2i(-1,-1)

func highlight_square(square: Vector2i) -> void:
	if square == last_board_pos:
		return

	if not on_screen(last_board_pos):
		highlight.show()


	if on_screen(square):
		print("Square: ", square)
		highlight.position = Vector2(square.x*TILE_SIZE, square.y*TILE_SIZE)
	else:
		highlight.hide()

	last_board_pos = square

func board_valid(num: int) -> bool:
	return (7 >= num) and (0 <= num)

@warning_ignore("integer_division")
func board_to_center(square: Vector2i) -> Vector2:
	return Vector2(
		square.x * TILE_SIZE + TILE_SIZE /2,
		square.y * TILE_SIZE + TILE_SIZE /2
	)

func make_piece_texture(col: int, row: int) -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = Rect2(col * PIECE_W, row*PIECE_H, PIECE_W, PIECE_H)
	return tex

func on_screen(board_pos: Vector2i) -> bool:
	if board_pos >= Vector2i(0,0):
		return true
	return false

func make_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var square := ColorRect.new()
			square.size = Vector2(TILE_SIZE,TILE_SIZE)
			square.position = Vector2(x*TILE_SIZE, y*TILE_SIZE)

			if (x + y) % 2 == 0:
				square.color = color_primary
			else:
				square.color = color_secondary

			$squares.add_child(square)

func make_piece(fen_char: String) -> Dictionary:
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
		"type": type,
		"color": color,
		"fen": fen_char,
		"has_moved": false
	}
	
func parse_fen_board(fen: String) -> Dictionary:
	var board := {}
	var ranks := fen.split("/")

	#there will be 8 ranks
	if len(ranks) != 8:
		push_error("Invalid FEN: Incorrect Number of ranks")
		return {}

	for rank in ranks:
		var x := 0
		
		for character in rank:

			if character in "12345678":
				x += int(character)
			else:

		
	return board

func parse_fen(fen: String) -> Dictionary:
	var parts := fen.strip_edges().split(" ")

	if parts.size() != 6:
		push_error("Invalid FEN: expected 6 fields")
		return {}

	var board := parse_fen_board(parts[0])
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

func algebraic_to_board(algebraic: String) -> Dictionary:
	return {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var board_pos := world_to_board(mouse_pos)
	highlight_square(board_pos)
	#print(1000/delta)
