class_name ItemSlot
extends Control

@export var item : Item

var cell_size = 64

@onready var texture_rect : TextureRect = %TextureRect

func _ready() -> void:
	display()
	var parent = get_parent()
	while true:
		if parent is InventoryPanel:
			if not parent.inventory: return
			cell_size = parent.inventory.cell_size
			break
		parent = parent.get_parent()
	custom_minimum_size = Vector2(cell_size,cell_size)

func display():
	texture_rect.texture = null
	texture_rect.rotation_degrees = 0
	if not item: return
	texture_rect.texture = item.icon
	texture_rect.size = item.get_dimensions(cell_size)
	texture_rect.rotation_degrees = item.rotation
	texture_rect.pivot_offset = Vector2i(cell_size/2,cell_size/2)
