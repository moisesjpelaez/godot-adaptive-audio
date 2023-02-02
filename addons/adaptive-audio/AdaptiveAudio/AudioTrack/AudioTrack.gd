tool
extends Node
class_name AudioTrack

signal transition_ended
signal track_stopped

var active_layers: Array = []
var is_playing: bool = false

onready var layers = $Content/Layers
onready var tween: Tween = $Tween
onready var base_track: AudioStreamPlayer = $Content/BaseTrack


func _ready() -> void:
	for layer in layers.get_children():
		layer.volume_db = -80


func play_track(layer_name: String = "") -> void:
	base_track.volume_db = 0
	base_track.play()
	
	if layer_name != "":
		layers.get_node(layer_name).volume_db = 0
	
	for layer in layers.get_children():
		layer.play()
	
	active_layers.clear()
	if layer_name != "":
		active_layers.append(layer_name)
	
	is_playing = true


func transition_to(layer_name: String = "") -> void:
	if layer_name != "":
		var layer_track: AudioStreamPlayer = layers.get_node(layer_name)
		if layer_track.volume_db != 0:
			tween.interpolate_property(layer_track, "volume_db", layer_track.volume_db, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
			yield(tween, "tween_all_completed")
	else:
		if active_layers.size() != 0:
			for current_layer_name in active_layers:
				if current_layer_name == layer_name:
					continue
				var current_layer_track: AudioStreamPlayer = layers.get_node(current_layer_name)
				tween.interpolate_property(current_layer_track, "volume_db", current_layer_track.volume_db, -80, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
			yield(tween, "tween_all_completed")
	
	if active_layers.size() != 0:
		for current_layer_name in active_layers:
			if current_layer_name == layer_name: 
				continue
			var current_layer_track: AudioStreamPlayer = layers.get_node(current_layer_name)
			tween.interpolate_property(current_layer_track, "volume_db", current_layer_track.volume_db, -80, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
	
	if !(layer_name in active_layers):
		active_layers.append(layer_name)
	
	emit_signal("transition_ended")


func play_layer(layer_name: String = "") -> void:
	if layer_name != "":
		var layer_track: AudioStreamPlayer = layers.get_node(layer_name)
		
		if layer_track.volume_db == 0: 
			return
		
		tween.interpolate_property(layer_track, "volume_db", layer_track.volume_db, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
	
	active_layers.append(layer_name)


func stop_track() -> void:
	if active_layers.size() != 0:
		for current_layer_name in active_layers:
			var layer_track: AudioStreamPlayer = layers.get_node(current_layer_name)
			tween.interpolate_property(layer_track, "volume_db", layer_track.volume_db, -80, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(base_track, "volume_db", base_track.volume_db, -80, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	base_track.stop()
	
	for layer in layers.get_children():
		layer.stop()
	
	is_playing = false
	active_layers.clear()
	emit_signal("track_stopped")


func add_layer() -> void:
	var audio_player = AudioStreamPlayer.new()
	layers.add_child(audio_player)
	audio_player.volume_db = -80


func update_layer(layer_index: int, new_name: String, new_path: String) -> void:
	var audio_player: AudioStreamPlayer = layers.get_child(layer_index)
	audio_player.name = new_name
	audio_player.stream = load(new_path)


func remove_layer(layer_index: int) -> void:
	layers.get_child(layer_index).queue_free()
