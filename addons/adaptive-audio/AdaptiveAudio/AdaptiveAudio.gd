tool
extends Node

const AUDIO_TRACK: PackedScene = preload("res://addons/adaptive-audio/AdaptiveAudio/AudioTrack/AudioTrack.tscn")
var current_track: AudioTrack


func play_track(track_name: String, fade_time: float = 0.5, layer_name: String = "") -> void:
	if current_track != null:
		if current_track.is_playing:
			if current_track.name != track_name:
				current_track.stop_track(fade_time)
				yield(current_track, "track_stopped")
			else:
				current_track.transition_to(layer_name, fade_time)
				return

	current_track = get_node(track_name)
	current_track.play_track(layer_name)


func transition_to(track_name: String, layer_name: String = "", fade_time: float = 0.5) -> void:
	if current_track == null: 
		return
	
	if current_track.is_transitioning:
		yield(current_track, "transition_ended")
	
	if current_track.name == track_name:
		current_track.transition_to(layer_name, fade_time)
	else:
		play_track(track_name, fade_time, layer_name)


func blend_layer(track_name: String, layer_name: String = "", fade_time: float = 0.5) -> void:
	if current_track == null: 
		return
	
	if current_track.is_transitioning:
		yield(current_track, "transition_ended")
	
	if current_track.name == track_name:
		current_track.blend_layer(layer_name, fade_time)
	else:
		play_track(track_name, fade_time, layer_name)


func stop_track(fade_time: float = 0.5) -> void:
	if current_track == null: 
		return
	
	if current_track.is_transitioning:
		yield(current_track, "transition_ended")
	
	current_track.stop_track(fade_time)


func add_track() -> void:
	var audio_track: AudioTrack = AUDIO_TRACK.instance()
	add_child(audio_track)


func update_track(track_index: int, new_name: String, new_path: String) -> void:
	var audio_track: AudioTrack = get_child(track_index)
	audio_track.name = new_name
	audio_track.base_track.stream = load(new_path)


func add_layer_to_track(track_index: int) -> void:
	var audio_track: AudioTrack = get_child(track_index)
	audio_track.add_layer()


func update_track_layer(track_index: int, layer_index: int, new_name: String, new_path: String) -> void:
	var audio_track: AudioTrack = get_child(track_index)
	audio_track.update_layer(layer_index, new_name, new_path)


func remove_layer_from_track(track_index: int, layer_index: int) -> void:
	var audio_track: AudioTrack = get_child(track_index)
	audio_track.remove_layer(layer_index)


func remove_track(track_index: int) -> void:
	var audio_track = get_child(track_index)
	if current_track == audio_track:
		current_track = null
	audio_track.queue_free()
