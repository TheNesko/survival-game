@tool
class_name IconMaker
extends EditorPlugin

const PLUGIN_NAME = "Icon Maker"
var dock

func _enter_tree() -> void:
	dock = preload("res://addons/iconmaker/IconMakerScene.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UR , dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
