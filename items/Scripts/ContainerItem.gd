class_name ContainerItem
extends EquipmentItem

@export var rows : int = 4
@export var columns : int = 2

var inventory : Inventory = Inventory.new(rows,columns)

func _ready():
	inventory = Inventory.new(rows,columns)

func deep_duplicate() -> Resource:
	var new_resource := self.duplicate(true)
	new_resource.inventory = Inventory.new(rows,columns)
	new_resource.inventory.grid = self.inventory.grid.duplicate(true)
	return new_resource

func equip():
	SignalManager.add_inventory.emit(inventory)

func unequip():
	SignalManager.remove_inventory.emit(inventory)
	inventory.drop_all_items()
