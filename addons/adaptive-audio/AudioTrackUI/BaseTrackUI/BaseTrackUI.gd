tool
extends VBoxContainer
class_name BaseTrackUI

onready var label: Label = $Label
onready var line_edit: LineEdit = $LineEdit

onready var file_label: Label = $HBoxContainer/Label
onready var select_audio_button: Button = $HBoxContainer/Select
onready var file_dialog: FileDialog = $FileDialog

onready var update_button: Button = $Update
onready var play_button: Button = $Play
onready var remove_button: Button = $Remove

signal audio_updated(track_name, stream_path)
signal track_started
signal track_removed

var stream_path: String

func _ready() -> void:
	select_audio_button.connect("pressed", self, "_on_Select_pressed")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	update_button.connect("pressed", self, "_on_Update_pressed")
	
	play_button.connect("pressed", self, "_on_Play_pressed")
	remove_button.connect("pressed", self, "_on_Remove_pressed")
	
	line_edit.text = label.text

func _on_Select_pressed() -> void:
	file_dialog.popup_centered(Vector2(512, 384))

func _on_FileDialog_file_selected(path: String) -> void:
	stream_path = path
	file_label.text = file_dialog.current_file
	update_audio()

func _on_Play_pressed() -> void:
	emit_signal("track_started")

func _on_Remove_pressed() -> void:
	emit_signal("track_removed")

func _on_Update_pressed() -> void:
	update_audio()

func update_audio() -> void:
	emit_signal("audio_updated", line_edit.text, stream_path)
