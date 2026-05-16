extends Node2D


const BOARD_SIZE := 8
const TILE_SIZE := 64


const STARTING_STATE := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
#const STARTING_STATE := "3k4/8/8/8/8/8/8/4K3 b KQkq - 0 1"

@export
var color_primary: Color
@export
var color_secondary: Color
@export
var highlight_color: Color
@export
var selection_color: Color

@onready var highlight: ColorRect = $squares/highlight
var last_board_pos := Vector2i(-1,-1)

@onready var peices_layer: Node = $Pieces

var board_state: BoardState

var current_board_highlights: Dictionary = {}

var selected_square:= Vector2i(-1,-1)

const PIECE_SCENES_WHITE := {
	Piece.Ptype.PAWN: preload("res://src/scene/pieces/white_pawn.tscn"),
	Piece.Ptype.ROOK: preload("res://src/scene/pieces/white_rook.tscn"),
	Piece.Ptype.KNIGHT: preload("res://src/scene/pieces/white_knight.tscn"),
	Piece.Ptype.BISHOP: preload("res://src/scene/pieces/white_bishop.tscn"),
	Piece.Ptype.QUEEN: preload("res://src/scene/pieces/white_queen.tscn"),
	Piece.Ptype.KING: preload("res://src/scene/pieces/white_king.tscn"),
}
const PIECE_SCENES_BLACK := {
	Piece.Ptype.PAWN: preload("res://src/scene/pieces/black_pawn.tscn"),
	Piece.Ptype.ROOK: preload("res://src/scene/pieces/black_rook.tscn"),
	Piece.Ptype.KNIGHT: preload("res://src/scene/pieces/black_knight.tscn"),
	Piece.Ptype.BISHOP: preload("res://src/scene/pieces/black_bishop.tscn"),
	Piece.Ptype.QUEEN: preload("res://src/scene/pieces/black_queen.tscn"),
	Piece.Ptype.KING: preload("res://src/scene/pieces/black_king.tscn"),
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

	cache_valid_moves_for(board_state.whose_turn())


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

	if on_screen(square):
		if not highlight.visible:
			highlight.show()
		print("Square: ", square)
		highlight.position = Vector2(square.x*TILE_SIZE, square.y*TILE_SIZE)
	else:
		highlight.hide()

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
		var color := piece.get_color()
		var piece_scene:PackedScene

		if color == BoardState.Turn.WHITE:
			piece_scene = PIECE_SCENES_WHITE.get(piece.get_type())
		else:
			piece_scene = PIECE_SCENES_BLACK.get(piece.get_type())

		
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
	show_vaild_moves(square)

func try_target_square(square: Vector2i):
	if board_state.attempt_move(selected_square, square):
		draw_board_state()
		cache_valid_moves_for(board_state.whose_turn())
	else:
		print("move failed")
	clear_move_highlights(true)

func cache_valid_moves_for(color : BoardState.Turn):
	var squares := board_state.get_color(color)
	for square in squares:
		var moves := MoveValidator.get_valid_moves(board_state, square)
		board_state.get_piece(square).set_moves(moves)

func show_vaild_moves(square: Vector2i):
	if not board_state.has_piece(square):
		return

	var valid_moves := board_state.get_piece(square).get_moves()
	
	for move in valid_moves:
		new_move_highlight(move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("ui_accept"):
		clear_move_highlights()

	if Input.is_action_just_pressed("DEBUG-PRINT_SELECTED"):
		print(selected_square)


	var mouse_pos := to_local(get_viewport().get_mouse_position())
	var board_pos := world_to_board(mouse_pos)
	if selected_square == Vector2i(-1,-1) or board_pos in current_board_highlights:
		highlight_under_cursor(board_pos)
	else:
		highlight.hide()


	last_board_pos = board_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var square := world_to_board(to_local(event.position))
			square_clicked(square)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_move_highlights()
		
