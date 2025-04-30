class_name Inventory
extends Node

signal item_added
signal item_removed

var cell_size : Vector2i = Vector2(64, 64)
var grid = []

@export_range(1,8) var columns : int = 5
@export_range(1,16) var rows : int = 5

func _ready():
	grid.resize(rows)
	for x in range(rows):
		grid[x] = []
		for y in range(columns):
			grid[x].append(null)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hotbar_1"):
		var item: Item = ItemStorage._get_item(1).data
		add_item(item)
	if Input.is_action_just_pressed("hotbar_2"):
		var item: Item = ItemStorage._get_item(2).data
		add_item(item)
	if Input.is_action_just_pressed("hotbar_3"):
		var item: Item = ItemStorage._get_item(0).data
		add_item(item)
		

func get_grid_position(local_position:Vector2) -> Vector2i:
	var pos : Vector2i = local_position
	var grid_position = pos / cell_size
	return grid_position

func add_item(item:Item):
	for col in columns:
		for row in rows:
			if add_item_to_pos(item,Vector2(row,col)):
				return true
	return false

func add_item_to_pos(item:Item,grid_pos:Vector2):
	item = item.duplicate()
	if not _can_add_item(item,grid_pos):
		item.rotated = not item.rotated
	if not _can_add_item(item,grid_pos):
		return false
	var columns = item.rows if item.rotated else item.columns
	var rows = item.columns if item.rotated else item.rows
	for col in columns:
		for row in rows:
			var x : int = grid_pos.x+row
			var y : int = grid_pos.y+col
			grid[x][y] = item
	item.origin = grid_pos
	item_added.emit()
	return true

func remove_item_from_pos(grid_pos:Vector2):
	if not _is_in_grid(grid_pos):
		return false
	var item = grid[grid_pos.x][grid_pos.y] as Item
	if not item: return
	var columns = item.rows if item.rotated else item.columns
	var rows = item.columns if item.rotated else item.rows
	for col in columns:
		for row in rows:
			var x : int = grid_pos.x+row
			var y : int = grid_pos.y+col
			grid[x][y] = null
	item_removed.emit()

func _drop_item(item:Item):
	if not item: return
	remove_item_from_pos(item.origin)
	var pos = get_parent().global_position
	ItemStorage.spawn_item(item.id,item.quantity,pos.x,pos.y,pos.z)

func _can_add_item(item:Item,grid_pos:Vector2) -> bool:
	var columns = item.rows if item.rotated else item.columns
	var rows = item.columns if item.rotated else item.rows
	for col in columns:
		for row in rows:
			var pos = grid_pos+Vector2(row,col)
			if not _is_in_grid(pos):
				return false
			if is_occupied(pos):
				return false
	return true

func _is_in_grid(grid_pos:Vector2) -> bool:
	if grid_pos.x < 0 or grid_pos.x > rows-1: return false
	if grid_pos.y < 0 or grid_pos.y > columns-1: return false
	return true

func is_occupied(grid_pos:Vector2) -> bool:
	if grid[grid_pos.x][grid_pos.y]:
		return true
	return false
