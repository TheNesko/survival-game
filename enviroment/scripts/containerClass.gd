class_name InventoryContainer
extends Entity

@export var inventory : Inventory
@export_range(1,16) var columns : int = 5
@export_range(1,16) var rows : int = 5

func _ready() -> void:
	inventory.columns = columns
	inventory.rows = rows
	inventory.set_up()
	inventory.add_item( ItemStorage._get_item( randi_range( 0, ItemStorage.items.size() -1 ) ).data )
	inventory.add_item( ItemStorage._get_item( randi_range( 0, ItemStorage.items.size() -1 ) ).data )

func interact():
	SignalManager.opened_container.emit(inventory)
