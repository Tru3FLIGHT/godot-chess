extends Node2D


const BOARD_SIZE := 8
const TILE_SIZE := 64

@export
var color_primary: Color
@export
var color_secondary: Color

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
	var board_pixels := BOARD_SIZE * TILE_SIZE
	get_window().size = Vector2i(board_pixels, board_pixels)
	make_board()

func board_to_world(square: Vector2i) -> Vector2:
	return Vector2(square.x * TILE_SIZE, square.y * TILE_SIZE)

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
