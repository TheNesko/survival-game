extends Control

@export var item_slot : PackedScene

var is_opened : bool = false
var drag_data : Dictionary
var can_drop : bool = false

@onready var inventory : Inventory = %Inventory
@onready var inventory_grid = %InventoryGrid
@onready var inventory_panel = %InventoryPanel



func _ready() -> void:
	inventory.item_added.connect(_update)
	inventory.item_removed.connect(_update)
	
	inventory_grid.columns = inventory.rows
	for column in inventory.columns:
		for row in inventory.rows:
			var slot = item_slot.instantiate()
			inventory_grid.add_child(slot)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		if is_opened: close()
		else: open()
	if Input.is_action_just_pressed("rotate"):
		drag_data.item.rotate()
		_can_drop_data(get_viewport().get_mouse_position(),drag_data)
	if Input.is_action_just_pressed("primary"):
		pass
	elif Input.is_action_just_pressed("secondary"):
		var pos = get_relative_mouse_position()
		var grid_pos = inventory.get_grid_position(pos)
		var slot = get_slot(grid_pos.x,grid_pos.y)
		inventory._drop_item(slot.item)

func _update():
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

func open():
	is_opened = true
	inventory_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	is_opened = false
	inventory_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_close_button_pressed() -> void:
	close()

func _set_drag_preview():
	var preview_texture = TextureRect.new()
	var preview = Control.new()
	preview_texture.texture = drag_data.item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2i(drag_data.item.rows,drag_data.item.columns) * inventory.cell_size
	preview_texture.position = -drag_data.offset
	preview_texture.modulate.a = 0.5
	if not can_drop:
		preview_texture.modulate.r = 0.5
		preview_texture.modulate.g = 0.0
		preview_texture.modulate.b = 0.0
	preview.add_child(preview_texture)
	set_drag_preview(preview)

func _get_drag_data(at_position: Vector2) -> Variant:
	var grid_pos = at_position - inventory_grid.global_position
	grid_pos = inventory.get_grid_position(grid_pos)
	var drag_item = inventory.grid[grid_pos.x][grid_pos.y] as Item
	if not drag_item: return
	var offset = at_position - get_slot(drag_item.origin.x,drag_item.origin.y).global_position
	drag_data = {"item":drag_item.duplicate(),"offset":offset}
	can_drop = false
	return drag_data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	_set_drag_preview()
	if not data: return false
	var grid_pos = at_position - inventory_grid.global_position
	grid_pos = inventory.get_grid_position(grid_pos)
	var offset = inventory.get_grid_position(data.offset)
	can_drop = inventory._can_add_item(data.item,grid_pos-offset)
	return can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var grid_pos = at_position - inventory_grid.global_position
	grid_pos = inventory.get_grid_position(grid_pos)
	inventory.remove_item_from_pos(data.item.origin)
	var offset = inventory.get_grid_position(data.offset)
	inventory.add_item_to_pos(data.item,grid_pos-offset)

#func _draw() -> void:
	#for row in inventory.rows:
		#for col in inventory.columns:
			#pass
