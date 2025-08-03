extends Sprite2D

@export var fish_textures: Array[Texture2D]

func _ready():
	hide()

func _on_fishing_minigame_fish_caught(success: bool) -> void:
	if success and not fish_textures.is_empty():
		show()
		texture = fish_textures.pick_random()
	else:
		hide()
