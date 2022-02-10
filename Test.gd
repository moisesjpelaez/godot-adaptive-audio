extends Control

func _ready() -> void:
	AdaptiveAudio.play_track("BaseTrack0", "Layer1")

	AdaptiveAudio.transition_to("BaseTrack1", "Layer0")

	AdaptiveAudio.stop_track()
