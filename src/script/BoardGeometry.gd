class_name BoardGeometry
extends RefCounted

static func board_to_world(square: Vector2i, tile_size: int) -> Vector2:
	return Vector2(square.x * tile_size, square.y * tile_size)

static func world_to_board(coord: Vector2, tile_size: int) -> Vector2i:
	var board := Vector2i(floor(coord.x/tile_size), floor(coord.y / tile_size))
	if board_valid(board.x) and board_valid(board.y):
		return board
	else: 
		return Vector2i(-1,-1)

static func board_valid(num: int) -> bool:
	return (7 >= num) and (0 <= num)

static func board_to_center(square: Vector2i, tile_size: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(
		square.x * tile_size + tile_size /2,
		square.y * tile_size + tile_size /2
	)

static func on_screen(board_pos: Vector2i) -> bool:
	if board_pos >= Vector2i(0,0) and board_pos <= Vector2i(7,7):
		return true
	return false
