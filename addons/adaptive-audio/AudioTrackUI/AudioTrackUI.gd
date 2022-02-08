tool
extends VBoxContainer
class_name AudioTrackUI

const LAYER_TRACK: PackedScene = preload("res://addons/adaptive-audio/AudioTrackUI/LayerTrackUI/LayerTrackUI.tscn")

onready var base_track_ui: Control = $Content/BaseTrackUI
onready var layers: HBoxContainer = $Content/Layers
onready var add_layer_button: Button = $Content/AddLayer

var current_track_name: String = ""
var current_layer_name: String = ""

signal base_track_updated(index, track_name, path)
signal layer_added(track_index)
signal layer_updated(track_index, layer_index, new_name, new_path)
signal layer_removed(track_index, layer_index)

signal transitioned(track_name, layer_name)

signal track_started(track_name, layer_name)
signal track_removed(index)

func _ready() -> void:
	add_layer_button.connect("pressed", self, "add_layer_track")
	
	base_track_ui.connect("audio_updated", self, "set_current_track_name")
	base_track_ui.connect("track_started", self, "play_pressed")
	base_track_ui.connect("track_removed", self, "remove_pressed")

func add_layer_track() -> void:
	var new_controls: Control = LAYER_TRACK.instance()
	layers.add_child(new_controls)
	new_controls.connect("audio_updated", self, "update_layer_track")
	new_controls.connect("transitioned", self, "transition_to")
	new_controls.connect("track_removed", self, "remove_layer_track")
	emit_signal("layer_added", get_index())
	
func update_layer_track(layer_index: int, new_name: String, new_path: String) -> void:
	emit_signal("layer_updated", get_index(), layer_index, new_name, new_path)

func transition_to(layer_name: String) -> void:
	emit_signal("transitioned", current_track_name, layer_name)

func remove_layer_track(index: int) -> void:
	layers.get_child(index).queue_free()
	emit_signal("layer_removed", get_index(), index)
	
func play_pressed() -> void:
	emit_signal("track_started", current_track_name)

func remove_pressed() -> void:
	emit_signal("track_removed", get_index())
	queue_free()

func set_current_track_name(new_name: String, new_path: String) -> void:
	current_track_name = new_name
	emit_signal("base_track_updated", get_index(), new_name, new_path)
