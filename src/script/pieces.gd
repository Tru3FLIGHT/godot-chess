const PIECE_W := 161
const PIECE_H := 155

const ATLAS := preload("res://clipart4559543.png")

func make_piece_texture(col: int, row: int) -> AtlasTexture:
    var tex := AtlasTexture.new()
    tex.atlas = ATLAS
    tex.region = Rect2(col * PIECE_W, row*PIECE_H, PIECE_W, PIECE_H)
    return tex