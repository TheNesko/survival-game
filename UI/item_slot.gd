class_name ItemSlot
extends TextureRect

@export var _item : Item = null

var cell_size = 64

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var parent = get_parent()
	cell_size = parent.inventory.cell_size
	custom_minimum_size = Vector2(cell_size,cell_size)
	display(_item)

func display(item=null):
	_item = item
	queue_redraw()
	texture = null
	rotation_degrees = 0
	if not _item: return
	texture = item.icon
	set_deferred("size",item.get_dimensions(cell_size))
	rotation_degrees = item.rotation
	pivot_offset = Vector2i(cell_size/2,cell_size/2)

func _draw() -> void:
	if not _item: return
	var rect_size = _item.get_dimensions(cell_size)
	var rect = Rect2(Vector2.ZERO,rect_size)
	#draw_texture_rect(_item.icon,rect,false)
