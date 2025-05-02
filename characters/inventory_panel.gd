class_name InventoryPanel
extends PanelContainer

@export var inventory_grid : GridContainer

var inventory : Inventory
var is_opened : bool = false
var drag_data : Dictionary
var can_drop : bool = false

@onready var close_button = find_child("CloseButton") as Button
@onready var item_slot : PackedScene = PrefabStorage.item_slot


func _ready() -> void:
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	if Input.is_action_just_pressed("primary"):
		pass
	elif Input.is_action_just_pressed("secondary"):
		var pos = get_relative_mouse_position()
		var grid_pos = inventory.get_grid_position(pos)
		var slot = get_slot(grid_pos.x,grid_pos.y)
		inventory._drop_item(slot.item)
	if not drag_data or not get_viewport().gui_is_dragging(): return
	if drag_data.target != self: return
	if Input.is_action_just_pressed("rotate") and Input.is_key_pressed(KEY_SHIFT):
		drag_data.item.rotate_counter_clockwise()
		_can_drop_data(get_viewport().get_mouse_position(),drag_data)
	elif Input.is_action_just_pressed("rotate"):
		drag_data.item.rotate_clockwise()
		_can_drop_data(get_viewport().get_mouse_position(),drag_data)

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful():
				var item = drag_data.original_item
				inventory.add_item_to_pos(item,item.origin)
			drag_data = {}

func _update():
	if inventory_grid.get_children().is_empty(): return
	for col in inventory.columns:
		for row in inventory.rows:
			var slot = get_slot(row,col)
			if inventory.is_occupied(Vector2(row,col)):
				var item = inventory.grid[row][col]
				if item: slot.item = inventory.grid[row][col]
				if item.origin == Vector2(row,col):
					slot.display()
			else: 
				slot.item = null
				slot.display()

func get_relative_mouse_position() -> Vector2:
	var pos = get_viewport().get_mouse_position()
	pos -= inventory_grid.global_position
	return pos

func get_slot(row:int,column:int) -> ItemSlot:
	var slot = inventory_grid.get_children()[row+(column*inventory.rows)] as ItemSlot
	return slot

func open(_inventory:Inventory):
	if not _inventory or is_opened: return
	inventory = _inventory
	inventory_grid.columns = inventory.rows
	for column in inventory.columns:
		for row in inventory.rows:
			var slot = item_slot.instantiate()
			inventory_grid.add_child(slot)
			slot.item = inventory.grid[column][row]
	is_opened = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update()
	inventory.item_added.connect(_update)
	inventory.item_removed.connect(_update)

func close():
	if not inventory or not is_opened: return
	for slot in inventory_grid.get_children():
		slot.queue_free()
	is_opened = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	inventory.item_added.disconnect(_update)
	inventory.item_removed.disconnect(_update)
	inventory = null

func _set_drag_preview():
	var preview_texture = TextureRect.new()
	var preview = Control.new()
	if not drag_data: return
	preview_texture.texture = drag_data.item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = drag_data.item.get_dimensions(64)
	preview.rotation_degrees = drag_data.item.rotation
	preview_texture.position -= Vector2(32,32)
	preview_texture.modulate.a = 0.5
	if not can_drop:
		preview_texture.modulate.r = 0.5
		preview_texture.modulate.g = 0.0
		preview_texture.modulate.b = 0.0
	preview.add_child(preview_texture)
	set_drag_preview(preview)

func _get_drag_data(at_position: Vector2) -> Variant:
	var grid_pos = at_position - inventory_grid.position
	grid_pos = inventory.get_grid_position(grid_pos)
	if not inventory._is_in_grid(grid_pos): return
	var drag_item = inventory.grid[grid_pos.x][grid_pos.y] as Item
	if not drag_item: return
	drag_data = {"item":drag_item.duplicate(),
			"original_item":drag_item,
			"target":self}
	inventory.remove_item_from_pos(drag_item.origin)
	return drag_data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data: return false
	data.target = self
	var grid_pos : Vector2i = at_position - inventory_grid.position
	grid_pos = inventory.get_grid_position(grid_pos)
	can_drop = inventory._can_add_item(data.item,grid_pos)
	_set_drag_preview()
	drag_data = data
	return can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var grid_pos = at_position - inventory_grid.position
	grid_pos = inventory.get_grid_position(grid_pos)
	inventory.add_item_to_pos(data.item,grid_pos)
