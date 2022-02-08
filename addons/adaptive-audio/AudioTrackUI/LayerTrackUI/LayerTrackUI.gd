tool
extends VBoxContainer
class_name LayerTrackUI

onready var label: Label = $Label
onready var line_edit: LineEdit = $LayerName

onready var file_label: Label = $HBoxContainer/Label
onready var select_button: Button = $HBoxContainer/Select

onready var transition_button: Button = $Transition

onready var set_button: Button = $Set
onready var file_dialog: FileDialog = $FileDialog
onready var remove_button: Button = $RemoveLayer

signal audio_updated(track_index, track_name, stream_path)
signal transitioned(track_name)
signal track_removed(index)

var stream_path: String

func _ready() -> void:
	select_button.connect("pressed", self, "_on_Select_pressed")
	set_button.connect("pressed", self, "_on_Set_pressed")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	transition_button.connect("pressed", self, "_on_TransitionButton_pressed")
	remove_button.connect("pressed", self, "_on_RemoveButton_pressed")
	
	label.text = "Layer " + str(get_index())
	line_edit.text = label.text
	line_edit.editable = false
	
	line_edit.connect("focus_entered", self, "on_LineEdit_focus_entered")
	line_edit.connect("focus_exited", self, "on_LineEdit_focus_exited")
	
func _on_Select_pressed() -> void:
	file_dialog.popup_centered(Vector2(512, 384))

func _on_FileDialog_file_selected(path: String) -> void:
	stream_path = path
	file_label.text = file_dialog.current_file
	emit_signal("audio_updated", get_index(), line_edit.text, stream_path)

func _on_Set_pressed() -> void:
	emit_signal("audio_updated", get_index(), line_edit.text, stream_path)

func _on_TransitionButton_pressed() -> void:
	emit_signal("transitioned", line_edit.text)

func _on_RemoveButton_pressed() -> void:
	emit_signal("track_removed", get_index())

func can_drop_data(position: Vector2, data) -> bool:
	return true
	
func drop_data(position: Vector2, data) -> void:
	stream_path = data.files[0]
	file_dialog.current_path = stream_path
	file_label.text = file_dialog.current_file
	emit_signal("audio_updated", get_index(), line_edit.text, stream_path)

func on_LineEdit_focus_entered() -> void:
	line_edit.editable = true

func on_LineEdit_focus_exited() -> void:
	line_edit.editable = false
	emit_signal("audio_updated", get_index(), line_edit.text, stream_path)
