tool
extends EditorPlugin

const MAIN_PANEL = preload("res://addons/adaptive-audio/MainScene.tscn")
var main_panel

func _enter_tree() -> void:
	main_panel = MAIN_PANEL.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel)
	make_visible(false)

func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()

func has_main_screen() -> bool:
	return true
	
func make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible

func get_plugin_name() -> String:
	return "Adaptive Audio"

func get_plugin_icon() -> Texture:
	return get_editor_interface().get_base_control().get_icon("AudioStreamPlayer", "EditorIcons")
