extends Control

@onready var inventory_panel = $InventoryPanel

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory") and not DEBUG.visible:
		inventory_panel.visible = !inventory_panel.visible
		if inventory_panel.visible: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not inventory_panel.visible: return
