extends Node2D


const BOARD_SIZE := 8
const TILE_SIZE := 64


const STARTING_STATE := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
#const STARTING_STATE := "r2qk1nr/p1p1p1pp/5p2/2Bp1bP1/1b1nP2P/5P2/PPPP4/R2QKBNR b KQkq - 0 1"

@export
var color_primary: Color
@export
var color_secondary: Color
@export
var highlight_color: Color
@export
var selection_color: Color

var pieceCLass = load("res://src/script/piece.gd")

@onready var highlight: ColorRect = $squares/highlight
var last_board_pos := Vector2i(-1,-1)

@onready var peices_layer: Node = $Pieces

var board_state: BoardState

var current_board_highlights: Dictionary = {}

var selected_square:= Vector2i(-1,-1)

const PIECE_W := 161
const PIECE_H := 155

const ATLAS := preload("res://clipart4559543.png")

const PIECE_SCENES := {
	"P": preload("res://src/scene/pieces/white_pawn.tscn"),
	"R": preload("res://src/scene/pieces/white_rook.tscn"),
	"N": preload("res://src/scene/pieces/white_knight.tscn"),
	"B": preload("res://src/scene/pieces/white_bishop.tscn"),
	"Q": preload("res://src/scene/pieces/white_queen.tscn"),
	"K": preload("res://src/scene/pieces/white_king.tscn"),
	"p": preload("res://src/scene/pieces/black_pawn.tscn"),
	"r": preload("res://src/scene/pieces/black_rook.tscn"),
	"n": preload("res://src/scene/pieces/black_knight.tscn"),
	"b": preload("res://src/scene/pieces/black_bishop.tscn"),
	"q": preload("res://src/scene/pieces/black_queen.tscn"),
	"k": preload("res://src/scene/pieces/black_king.tscn"),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	make_board()
	highlight.move_to_front()
	highlight.color = highlight_color
	highlight.size = Vector2(TILE_SIZE,TILE_SIZE)
	highlight.position = board_to_world(last_board_pos)
	highlight.hide()

	var state := FenParser.parse(STARTING_STATE)
	board_state = BoardState.new(state)
	draw_board_state()


func board_to_world(square: Vector2i) -> Vector2:
	return Vector2(square.x * TILE_SIZE, square.y * TILE_SIZE)

func world_to_board(coord: Vector2) -> Vector2i:
	var board := Vector2i(floor(coord.x/TILE_SIZE), floor(coord.y / TILE_SIZE))
	if board_valid(board.x) and board_valid(board.y):
		return board
	else: 
		return Vector2i(-1,-1)


func board_valid(num: int) -> bool:
	return (7 >= num) and (0 <= num)

func board_to_center(square: Vector2i) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(
		square.x * TILE_SIZE + TILE_SIZE /2,
		square.y * TILE_SIZE + TILE_SIZE /2
	)

func highlight_under_cursor(square: Vector2i) -> void:
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

func new_move_highlight(square: Vector2i, selection := false) -> void:
	if not on_screen(square):
		push_error("Cannot highlight square: ", square, " --- Not on board")
		return
	
	if square in current_board_highlights.keys():
		return

	current_board_highlights[square] = true if selection else false
	var new_highlight := highlight.duplicate()

	$squares/move_highlights.add_child(new_highlight)
	new_highlight.show()
	if selection:
		new_highlight.color = selection_color
	else:
		new_highlight.color = highlight_color

	new_highlight.position = Vector2(square.x*TILE_SIZE, square.y*TILE_SIZE)

func clear_move_highlights(clear_selection:=true) -> void:
	current_board_highlights = {}
	if clear_selection:
		selected_square = Vector2i(-1,-1)
	for child in $squares/move_highlights.get_children():
		child.queue_free()

func draw_board_state() -> void:
	for child in peices_layer.get_children():
		child.queue_free()

	for square in board_state.board.keys():
		var piece: Piece = board_state.board[square]
		var fen: String = piece.fen_char

		if not PIECE_SCENES.has(fen):
			push_error("Missing piece scene for FEN: ", fen)
			continue
		
		var piece_scene:PackedScene = PIECE_SCENES[fen]
		var piece_node := piece_scene.instantiate() as TextureRect

		if piece_node == null:
			push_error("Piece scene root must be TextureRect: " + fen)
			continue
		
		piece_node.scale = Vector2(0.40, 0.40)
		piece_node.position = board_to_world(square)  
		peices_layer.add_child(piece_node)

func on_screen(board_pos: Vector2i) -> bool:
	if board_pos >= Vector2i(0,0) and board_pos <= Vector2i(7,7):
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

func square_clicked(square: Vector2i) -> void:
	if not on_screen(square):
		clear_move_highlights()
		return

	if selected_square == Vector2i(-1,-1):
		try_select_square(square)
	else:
		try_target_square(square)

func try_select_square(square: Vector2i):
	if not board_state.has_piece(square):
		return
	
	clear_move_highlights(false)
	selected_square = square
	new_move_highlight(square, true)

func try_target_square(square: Vector2i):
	board_state.attempt_move(selected_square, square)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_accept"):
		clear_move_highlights()

	var mouse_pos := to_local(get_viewport().get_mouse_position())
	var board_pos := world_to_board(mouse_pos)
	highlight_under_cursor(board_pos)
	#print(1000/_delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var square := world_to_board(to_local(event.position))
			square_clicked(square)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_move_highlights()
		
