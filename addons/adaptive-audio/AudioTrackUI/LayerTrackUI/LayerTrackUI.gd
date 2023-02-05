tool
extends Control
class_name LayerTrackUI

signal audio_updated(track_index, track_name, stream_path)
signal transitioned(track_name, fade_time)
signal blended(layer_name, fade_time)
signal track_removed(index)

var stream_path: String

onready var title: Label = $Content/Title
onready var layer_name_edit: LineEdit = $Content/LayerName

onready var fade_spin_box: SpinBox = $Content/FadeTime/SpinBox
onready var fade_slider: HSlider = $Content/FadeTime/HSlider

onready var file_label: Label = $Content/FileButtons/Label
onready var select_button: Button = $Content/FileButtons/Select

onready var transition_button: Button = $Content/LayerButtons/Transition
onready var blend_button: Button = $Content/LayerButtons/Blend

onready var set_button: Button = $Content/LayerButtons/Set
onready var remove_button: Button = $Content/LayerButtons/RemoveLayer

onready var file_dialog: FileDialog = $FileDialog


func _ready() -> void:
	select_button.connect("pressed", self, "_on_Select_pressed")
	set_button.connect("pressed", self, "_on_Set_pressed")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	
	fade_spin_box.connect("value_changed", self, "_on_SpinBox_value_changed")
	fade_slider.connect("value_changed", self, "_on_Slider_value_changed")
	
	transition_button.connect("pressed", self, "_on_Transition_pressed")
	blend_button.connect("pressed", self, "_on_Blend_pressed")
	
	remove_button.connect("pressed", self, "_on_RemoveButton_pressed")
	
	title.text = "Layer" + str(get_index())
	
	layer_name_edit.text = title.text
	layer_name_edit.editable = false
	
	layer_name_edit.connect("focus_entered", self, "_on_LineEdit_focus_entered")
	layer_name_edit.connect("focus_exited", self, "_on_LineEdit_focus_exited")
	layer_name_edit.connect("gui_input", self, "_on_LineEdit_gui_input")


func set_layer_data(value: String, path: String) -> void:
	layer_name_edit.text = value
	layer_name_edit.editable = false
	
	stream_path = path
	file_dialog.current_path = path
	file_label.text = file_dialog.current_file


func can_drop_data(position: Vector2, data) -> bool:
	return typeof(data.files[0]) == TYPE_STRING and (data.files[0].get_extension() == "ogg" or data.files[0].get_extension() == "wav" or data.files[0].get_extension() == "mp3")


func drop_data(position: Vector2, data) -> void:
	stream_path = data.files[0]
	file_dialog.current_path = stream_path
	file_label.text = file_dialog.current_file
	emit_signal("audio_updated", get_index(), layer_name_edit.text, stream_path)


func _on_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			layer_name_edit.release_focus()


func _on_LineEdit_focus_entered() -> void:
	layer_name_edit.editable = true


func _on_LineEdit_focus_exited() -> void:
	layer_name_edit.editable = false
	emit_signal("audio_updated", get_index(), layer_name_edit.text, stream_path)


func _on_SpinBox_value_changed(value: float) -> void:
	fade_slider.value = value


func _on_Slider_value_changed(value: float) -> void:
	fade_spin_box.value = value


func _on_Select_pressed() -> void:
	file_dialog.popup_centered(Vector2(512, 384))


func _on_FileDialog_file_selected(path: String) -> void:
	stream_path = path
	file_label.text = file_dialog.current_file
	emit_signal("audio_updated", get_index(), layer_name_edit.text, stream_path)


func _on_Set_pressed() -> void:
	emit_signal("audio_updated", get_index(), layer_name_edit.text, stream_path)


func _on_Transition_pressed() -> void:
	emit_signal("transitioned", layer_name_edit.text, fade_spin_box.value)


func _on_Blend_pressed() -> void:
	emit_signal("blended", layer_name_edit.text, fade_spin_box.value)


func _on_RemoveButton_pressed() -> void:
	emit_signal("track_removed", get_index())
