extends Label

var normal_fish_lines = [
	"It flops quietly in your hands.",
	"You could sell this at the market.",
	"A gentle tug. Nothing more.",
	"Just a fish... probably.",
	"YOU ARE NOT ALONE",
	"It saw you first."
]

func _on_rod_reeling_finished() -> void:
	text = normal_fish_lines.pick_random()
