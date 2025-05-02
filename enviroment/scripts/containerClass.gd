class_name InventoryContainer
extends Entity

@export var inventory : Inventory
@export_range(1,16) var columns : int = 5
@export_range(1,16) var rows : int = 5

func _ready() -> void:
	inventory.columns = columns
	inventory.rows = rows
	inventory.set_up()

func interact():
	return inventory
