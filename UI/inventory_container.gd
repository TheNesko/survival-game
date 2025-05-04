extends PanelContainer



func add_container(inventory:Inventory):
	var container = $ScrollContainer/VBoxContainer
	var inventory_grid_container = PrefabStorage.inventory_grid_container.instantiate()
	container.add_child(inventory_grid_container)
	var inventory_grid = inventory_grid_container.get_node("InventoryGrid")
	inventory_grid.set_inventory(inventory)
	return inventory_grid
