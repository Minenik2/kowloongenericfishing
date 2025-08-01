extends AudioStreamPlayer

@export var music_player: AudioStreamPlayer
@export var songs: Array[AudioStream] = []

func _ready() -> void:
	play_random_song()

func play_random_song():
	var random_index = randi() % songs.size()
	music_player.stream = songs[random_index]
	music_player.play()
	music_player.connect("finished", Callable(self, "_on_music_finished"))

func _on_music_finished():
	music_player.disconnect("finished", Callable(self, "_on_music_finished"))
	play_random_song()

func stop_music():
	music_player.stop()
	music_player.disconnect("finished", Callable(self, "_on_music_finished"))
