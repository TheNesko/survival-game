class_name Inventory
extends Node

signal item_added(item:Item)
signal item_removed(item:Item)

@export var inventory_name : String = "Container"
var grid = []

@export_range(16,128,16) var cell_size : int = 32
@export_range(1,8) var columns : int = 5
@export_range(1,16) var rows : int = 5

func _ready():
	set_up()

func set_up():
	grid.resize(rows)
	for x in range(rows):
		grid[x] = []
		for y in range(columns):
			grid[x].append(null)

func get_grid_position(local_position:Vector2) -> Vector2i:
	var pos : Vector2i = local_position
	var grid_position = pos / cell_size
	return grid_position

func add_item(item:Item):
	# checks for the first avalible space to add the item
	for col in columns:
		for row in rows:
			for x in range(4):
				if _can_add_item(item,Vector2(row,col)):
					add_item_to_pos(item,Vector2(row,col))
					return true
				item.rotate_clockwise()
	return false

func remove_item(item:Item):
	for col in columns:
		for row in rows:
			if grid[row][col] == item:
				remove_item_from_pos(Vector2i(row,col))
			

func remove_item_from_pos(grid_pos:Vector2i):
	if not _is_in_grid(grid_pos):
		return false
	var item = grid[grid_pos.x][grid_pos.y] as Item
	if not item: return
	#new
	for cell in item.shape:
		var pos : Vector2i = grid_pos + cell
		grid[pos.x][pos.y] = null
	item_removed.emit(item)
	return true

func add_item_to_pos(item:Item,grid_pos:Vector2i):
	if is_occupied(grid_pos): return false
	item = item.duplicate()
	# check if item can be added in any of the 4 rotations
	# if it then change can_add = true and break from the for loop
	# then go through all the cells and assign the item to the grid positions
	# assign item's origin position if cell is equal [0,0]
	for cell in item.shape:
		var pos : Vector2i = grid_pos + cell
		grid[pos.x][pos.y] = item
		if cell == Vector2i.ZERO: 
			item.origin = pos
	item_added.emit(item)
	return true

func _drop_item(item:Item):
	if not item: return
	remove_item_from_pos(item.origin)
	var pos = get_parent().global_position
	ItemStorage.spawn_item(item.id,item.quantity,pos.x,pos.y,pos.z)

func _can_add_item(item:Item,grid_pos:Vector2i) -> bool:
	# checks in all cells of the item shape fit in the grid
	for cell in item.shape:
		var pos : Vector2i = grid_pos + cell
		if not _is_in_grid(pos):
			return false
		if is_occupied(pos):
			return false
	return true

func _is_in_grid(grid_pos:Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x > rows-1: return false
	if grid_pos.y < 0 or grid_pos.y > columns-1: return false
	return true

func is_occupied(grid_pos:Vector2i) -> bool:
	if not _is_in_grid(grid_pos): return true
	if grid[grid_pos.x][grid_pos.y]:
		return true
	return false
