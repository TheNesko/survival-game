class_name ItemSlot
extends Control

@export var item : Item

@onready var texture_rect : TextureRect = %TextureRect

func _ready() -> void:
	display()

func display():
	texture_rect.texture = null
	texture_rect.rotation_degrees = 0
	if not item: return
	texture_rect.texture = item.icon
	texture_rect.size = item.get_dimensions(64)
	texture_rect.rotation_degrees = item.rotation
	texture_rect.pivot_offset = Vector2i(32,32)
