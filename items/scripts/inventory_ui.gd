extends Control

@onready var inventory_panel = $InventoryPanel

func _ready() -> void:
	SignalBus.item_added.connect(update_slot)
	SignalBus.item_removed.connect(update_slot)
	SignalBus.item_drop.connect(update_slot)
	SignalBus.equipment_changed.connect(update_slot)
	SignalBus.update_slots.connect(update_slots)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: inventory_panel.visible = false
	else: inventory_panel.visible = true

func update_slot(slot):
	slot.update()

func update_slots():
	for child in get_tree().get_nodes_in_group("ItemSlots"):
		child.update()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory") and not DEBUG.visible:
		inventory_panel.visible = !inventory_panel.visible
		if inventory_panel.visible: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not inventory_panel.visible: return
