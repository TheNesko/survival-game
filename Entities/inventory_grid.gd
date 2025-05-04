class_name InventoryGrid
extends GridContainer

var inventory : Inventory
var is_opened : bool = false
var drag_data : Dictionary
var can_drop : bool = false

func _ready() -> void:
	add_theme_constant_override("h_separation",0)
	add_theme_constant_override("v_separation",0)

func set_inventory(new_value:Inventory):
	if new_value == null:
		inventory = null
		for child in get_children():
			child.queue_free()
		return
	inventory = new_value
	inventory.item_added.connect(_update)
	inventory.item_removed.connect(_update)
	if not get_children().is_empty():
		for child in get_children():
			child.queue_free()
	columns = inventory.rows
	for column in inventory.columns:
		for row in inventory.rows:
			var slot = PrefabStorage.item_slot.instantiate()
			add_child(slot)
			slot.item = inventory.grid[row][column]
	_update()

func _unhandled_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	if not drag_data or not get_viewport().gui_is_dragging(): return
	queue_redraw()
	if drag_data.target != self: return
	if Input.is_action_just_pressed("rotate") and Input.is_key_pressed(KEY_SHIFT):
		drag_data.item.rotate_counter_clockwise()
		_can_drop_data(get_relative_mouse_position(),drag_data)
	elif Input.is_action_just_pressed("rotate"):
		drag_data.item.rotate_clockwise()
		_can_drop_data(get_relative_mouse_position(),drag_data)

func _gui_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	if not inventory: return
	var pos = get_relative_mouse_position()
	var grid_pos = inventory.get_grid_position(pos)
	var slot = get_slot(grid_pos.x,grid_pos.y)
	if not slot: return
	if Input.is_action_just_released("primary"):
		if slot.item: slot.item.use()
	elif Input.is_action_just_released("secondary"):
		inventory._drop_item(slot.item)

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful() and drag_data:
				var item = drag_data.original_item
				drag_data.target.inventory.remove_item(drag_data.item)
				if drag_data.origin == self:
					if not inventory.add_item(item):
						var pos = inventory.get_parent().position  
						ItemStorage.spawn_item(item.id,item.quantity,pos.x,pos.y,pos.z)
			drag_data = {}
			queue_redraw()

func _update(_item=null):
	if get_children().is_empty(): return
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
	pos -= global_position
	return pos

func get_cell_global_position(grid_pos:Vector2i) -> Vector2:
	var pos = Vector2(grid_pos.x*inventory.cell_size,grid_pos.x*inventory.cell_size)
	return pos + global_position

func get_slot(row:int,column:int) -> ItemSlot:
	if not inventory._is_in_grid(Vector2i(row,column)) or get_children().is_empty(): return
	var slot = get_children()[row+(column*inventory.rows)] as ItemSlot
	return slot


func _set_drag_preview():
	var preview_texture = TextureRect.new()
	var preview = Control.new()
	if not drag_data: return
	preview_texture.texture = drag_data.item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = drag_data.item.get_dimensions(inventory.cell_size)
	preview.rotation_degrees = drag_data.item.rotation
	preview_texture.position -= Vector2(inventory.cell_size/2,inventory.cell_size/2)
	preview_texture.modulate.a = 0.5
	if not can_drop:
		preview_texture.modulate.r = 0.5
		preview_texture.modulate.g = 0.0
		preview_texture.modulate.b = 0.0
	preview.add_child(preview_texture)
	set_drag_preview(preview)

func _get_drag_data(at_position: Vector2) -> Variant:
	var grid_pos = at_position
	if grid_pos.x < 0 or grid_pos.y < 0: return
	grid_pos = inventory.get_grid_position(grid_pos)
	if not inventory._is_in_grid(grid_pos): return
	var drag_item = inventory.grid[grid_pos.x][grid_pos.y] as Item
	if not drag_item: return
	drag_data = {"item":drag_item.duplicate(),
			"original_item":drag_item,
			"origin":self,
			"target":self}
	inventory.remove_item_from_pos(drag_item.origin)
	return drag_data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data: return false
	data.target = self
	var grid_pos : Vector2i = at_position
	grid_pos = inventory.get_grid_position(grid_pos)
	can_drop = inventory._can_add_item(data.item,grid_pos)
	drag_data = data
	_set_drag_preview()
	queue_redraw()
	return can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var grid_pos = at_position
	grid_pos = inventory.get_grid_position(grid_pos)
	inventory.add_item_to_pos(data.item,grid_pos)

func _draw() -> void:
	var color = Color(0.1,0.1,0.1,0.9)
	if not drag_data: return
	if drag_data.target != self: return
	for cell in drag_data.item.shape:
		var cell_size = inventory.cell_size
		var mouse_pos = get_relative_mouse_position()
		var grid_pos = inventory.get_grid_position(mouse_pos)
		grid_pos += cell
		var pos = grid_pos*cell_size
		if not inventory._is_in_grid(grid_pos): continue
		if inventory.is_occupied(grid_pos) or not can_drop:
			color.r = 0.6
		var rect = Rect2(pos.x,pos.y,cell_size,cell_size)
		draw_rect(rect,color)
