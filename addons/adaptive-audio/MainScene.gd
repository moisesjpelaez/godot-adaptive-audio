tool
extends Panel

const AUDIO_TRACK_UI: PackedScene = preload("res://addons/adaptive-audio/AudioTrackUI/AudioTrackUI.tscn")

onready var buttons_container: HBoxContainer = $Buttons
onready var stop_button: Button = buttons_container.get_node("Stop")
onready var add_button: Button = buttons_container.get_node("Add")
onready var save_button: Button = buttons_container.get_node("Save")
onready var load_button: Button = buttons_container.get_node("Load")

onready var file_dialog: FileDialog = $FileDialog

onready var tracks_container: ScrollContainer = $MainPanel/AudioTracks
onready var audio_tracks: VBoxContainer = tracks_container.get_node("VBoxContainer")

onready var adaptive_audio: Node = $AdaptiveAudio


func _ready() -> void:
	stop_button.connect("pressed", self, "_on_Stop_pressed")
	add_button.connect("pressed", self, "_on_Add_pressed")
	save_button.connect("pressed", self, "_on_Save_pressed")
	load_button.connect("pressed", self, "_on_Load_pressed")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	

func set_new_owner(node: Node) -> void:
	if node == null:
		return

	node.set_owner(adaptive_audio)
	
	for child in node.get_children():
		set_new_owner(child)


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


func play_track(track_name: String, fade_time: float, layer_name: String) -> void:
	adaptive_audio.play_track(track_name, fade_time, layer_name)


func transition_to(track_name: String, layer_name: String, fade_time: float) -> void:
	adaptive_audio.transition_to(track_name, layer_name, fade_time)


func blend_layer(track_name: String, layer_name: String, fade_time: float) -> void:
	adaptive_audio.blend_layer(track_name, layer_name, fade_time)


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
	audio_track_ui.connect("blended", self, "blend_layer")
	
	add_track()


func _on_Stop_pressed() -> void:
	adaptive_audio.stop_track()


func _on_Save_pressed() -> void:
	for node in adaptive_audio.get_children():
		node.set_filename("")
		set_new_owner(node)
	
	var adaptive_audio_scene: PackedScene = PackedScene.new()
	adaptive_audio_scene.pack(adaptive_audio)

	var dir: Directory = Directory.new()
	if !dir.dir_exists("res://Autoload/"):
		dir.make_dir("res://Autoload/")

	ResourceSaver.save("res://Autoload/AdaptiveAudio.tscn", adaptive_audio_scene)


func _on_Load_pressed() -> void:
	file_dialog.popup_centered(Vector2(512, 384))


func _on_FileDialog_file_selected(path: String) -> void:
	var adaptive_audio_node: Node = load(path).instance()
	
	if adaptive_audio_node.name != "AdaptiveAudio":
		printerr("The selected scene isn't an 'AdaptiveAudio' node.")
		adaptive_audio_node.queue_free()
		return
	
	for audio_track in audio_tracks.get_children():
		audio_track.remove_pressed()
		yield(audio_track, "tree_exited")
	
	for i in adaptive_audio_node.get_children().size():
		_on_Add_pressed()
		var audio_track: AudioTrack = adaptive_audio_node.get_child(i)
		var audio_track_ui: AudioTrackUI = audio_tracks.get_child(i)
		audio_track_ui.set_base_track_name(audio_track.name)
		audio_track_ui.set_current_track_name(audio_track.name, audio_track.get_node("Content/BaseTrack").stream.resource_path)
		
		for j in audio_track.get_node("Content/Layers").get_child_count():
			var layer_track: AudioStreamPlayer = audio_track.get_node("Content/Layers").get_child(j)
			var layer_track_ui: LayerTrackUI = audio_track_ui.add_layer_track()
			layer_track_ui.set_layer_data(layer_track.name, layer_track.stream.resource_path)
			layer_track_ui.emit_signal("audio_updated", j, layer_track.name, layer_track.stream.resource_path)
	
	adaptive_audio_node.queue_free()
