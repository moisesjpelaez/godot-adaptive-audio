tool
extends Control

const AUDIO_TRACK_UI: PackedScene = preload("res://addons/adaptive-audio/AudioTrackUI/AudioTrackUI.tscn")

onready var buttons_container: HBoxContainer = $Buttons
onready var stop_button: Button = buttons_container.get_node("Stop")
onready var add_button: Button = buttons_container.get_node("Add")
onready var create_button: Button = buttons_container.get_node("Create")

onready var tracks_container: ScrollContainer = $MainPanel/AudioTracks
onready var audio_tracks: VBoxContainer = tracks_container.get_node("VBoxContainer")

onready var adaptive_audio: Node = $AdaptiveAudio

func _ready() -> void:
	stop_button.connect("pressed", self, "_on_Stop_pressed")
	add_button.connect("pressed", self, "_on_Add_pressed")
	create_button.connect("pressed", self, "_on_Create_pressed")

func _on_Add_pressed() -> void:
	var audio_track_ui: AudioTrackUI = AUDIO_TRACK_UI.instance()
	audio_tracks.add_child(audio_track_ui)
	
	audio_track_ui.connect("base_track_updated", self, "update_track")
	audio_track_ui.connect("layer_added", self, "add_layer")
	audio_track_ui.connect("layer_updated", self, "update_layer")
	audio_track_ui.connect("layer_removed", self, "remove_layer")
	audio_track_ui.connect("track_removed", self, "remove_track")
	
	audio_track_ui.connect("track_started", self, "play_track")
	audio_track_ui.connect("transitioned", self, "transition_to")
	
	add_track()

func add_track() -> void:
	adaptive_audio.add_track()
	
func update_track(track_index: int, track_name: String, path: String) -> void:
	adaptive_audio.update_track(track_index, track_name, path)

func add_layer(track_index: int) -> void:
	adaptive_audio.add_layer_to_track(track_index)

func update_layer(track_index: int, layer_index: int, new_name: String, new_path: String) -> void:
	adaptive_audio.update_track_layer(track_index, layer_index, new_name, new_path)

func remove_layer(track_index: int, layer_index: int) -> void:
	adaptive_audio.remove_layer_from_track(track_index, layer_index)

func remove_track(track_index: int) -> void:
	adaptive_audio.remove_track(track_index)

func play_track(track_name: String, layer_name: String = "") -> void:
	adaptive_audio.play_track(track_name, layer_name)

func transition_to(track_name: String, layer_name: String) -> void:
	adaptive_audio.transition_to(track_name, layer_name)

func _on_Stop_pressed() -> void:
	adaptive_audio.stop_track()

func _on_Create_pressed() -> void:
	for node in adaptive_audio.get_children():
		node.set_filename("")
		iterate_children(node)
	
	var adaptive_audio_scene = PackedScene.new()
	adaptive_audio_scene.pack(adaptive_audio)

	var dir: Directory = Directory.new()
	if !dir.dir_exists("res://addons/adaptive-audio/Autoload/"):
		dir.make_dir("res://addons/adaptive-audio/Autoload/")

	ResourceSaver.save("res://addons/adaptive-audio/Autoload/AdaptiveAudio.tscn", adaptive_audio_scene)

func iterate_children(node: Node) -> void:
	if node == null:
		return

	node.set_owner(adaptive_audio)
	
	for child in node.get_children():
		iterate_children(child)
