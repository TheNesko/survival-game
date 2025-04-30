class_name ItemSlot
extends Control

@export var item : Item

@onready var texture_rect : TextureRect = %TextureRect

func _ready() -> void:
	display()

func display():
	if not item:
		texture_rect.texture = null
		return
	texture_rect.texture = item.icon
	texture_rect.size.x = item.rows*64
	texture_rect.size.y = item.columns*64
	texture_rect.pivot_offset = size / Vector2(2,2)
	if item.rotated: texture_rect.rotation = deg_to_rad(90)
	else: texture_rect.rotation = deg_to_rad(0)

#func _draw():
	#if not item: return
	#var rect = Rect2(0, 0,item.rows*64,item.columns*64)
	#draw_texture_rect(item.icon,rect,false)
