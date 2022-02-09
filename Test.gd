extends Control

func _ready() -> void:
	AdaptiveAudio.play_track("Indoor", "House")

func _on_Timer_timeout() -> void:
	AdaptiveAudio.transition_to("Indoor", "Basement")
