class_name Render
extends RefCounted

var highlight : TextureRect
var mv_highlights : Node

func _init(highl : TextureRect)

func highlight_under_cursor(square: Vector2i) -> void:
	if square == last_board_pos:
		return

	clear_move_highlights()

	if not on_screen(last_board_pos):
		highlight.show()


	if on_screen(square):
		print("Square: ", square)
		highlight.position = Vector2(square.x*TILE_SIZE, square.y*TILE_SIZE)
	else:
		highlight.hide()

	last_board_pos = square

func new_move_highlight(square: Vector2i) -> void:
	if not on_screen(square):
		push_error("Cannot highlight square: ", square, " --- Not on board")
		return
	
	if square in current_board_highlights.keys():
		return

	current_board_highlights[square] = null
	var new_highlight := highlight.duplicate()

	mv_highlights.add_child(new_highlight)
	new_highlight.show()
	new_highlight.color = highlight_color
	new_highlight.position = Vector2(square.x*TILE_SIZE, square.y*TILE_SIZE)

func clear_move_highlights() -> void:
	current_board_highlights = {}
	for child in mv_highlights.get_children():
		child.queue_free()

func draw_board_state() -> void:
	for child in peices_layer.get_children():
		child.queue_free()

	for square in board_state.keys():
		var piece: Dictionary = board_state[square]
		var fen: String = piece["fen"]

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
		