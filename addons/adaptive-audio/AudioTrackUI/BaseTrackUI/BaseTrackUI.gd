tool
extends Panel
class_name BaseTrackUI

signal audio_updated(track_name, stream_path)
signal track_started(fade_time)
signal track_removed

var stream_path: String

onready var title: Label = $Content/Title
onready var track_name_edit: LineEdit = $Content/TrackName
onready var fade_slider: HSlider = $Content/FadeTime

onready var file_label: Label = $Content/FileButtons/Label
onready var select_audio_button: Button = $Content/FileButtons/Select
onready var file_dialog: FileDialog = $FileDialog

onready var update_button: Button = $Content/TrackButtons/Update
onready var play_button: Button = $Content/TrackButtons/Play
onready var remove_button: Button = $Content/TrackButtons/Remove


func _ready() -> void:
	yield(owner, "ready")
	
	select_audio_button.connect("pressed", self, "_on_Select_pressed")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	update_button.connect("pressed", self, "_on_Update_pressed")
	
	play_button.connect("pressed", self, "_on_Play_pressed")
	remove_button.connect("pressed", self, "_on_Remove_pressed")
	
	track_name_edit.editable = false
	
	track_name_edit.connect("focus_entered", self, "_on_LineEdit_focus_entered")
	track_name_edit.connect("focus_exited", self, "_on_LineEdit_focus_exited")
	
	track_name_edit.connect("gui_input", self, "_on_LineEdit_gui_input")


func update_audio() -> void:
	emit_signal("audio_updated", track_name_edit.text, stream_path)


func can_drop_data(position: Vector2, data) -> bool:
	return typeof(data.files[0]) == TYPE_STRING and (data.files[0].get_extension() == "ogg" or data.files[0].get_extension() == "wav" or data.files[0].get_extension() == "mp3")


func drop_data(position: Vector2, data) -> void:
	stream_path = data.files[0]
	file_dialog.current_path = stream_path
	file_label.text = file_dialog.current_file
	update_audio()


func _on_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			track_name_edit.release_focus()


func _on_LineEdit_focus_entered() -> void:
	track_name_edit.editable = true


func _on_LineEdit_focus_exited() -> void:
	track_name_edit.editable = false
	update_audio()


func _on_Select_pressed() -> void:
	file_dialog.popup_centered(Vector2(512, 384))


func _on_FileDialog_file_selected(path: String) -> void:
	stream_path = path
	file_label.text = file_dialog.current_file
	update_audio()


func _on_Play_pressed() -> void:
	emit_signal("track_started", fade_slider.value)


func _on_Remove_pressed() -> void:
	emit_signal("track_removed")


func _on_Update_pressed() -> void:
	update_audio()
