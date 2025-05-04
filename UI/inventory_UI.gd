extends HBoxContainer

var inventory_grids : Array[InventoryGrid]

@onready var external_grid = $VBoxContainer/CenterContainer/InventoryGrid

func _init() -> void:
	SignalManager.opened_container.connect(open_container_inventory)
	SignalManager.add_inventory.connect(add_inventory)

func _unhandled_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	if Input.is_action_just_released("inventory"):
		if get_parent().visible: close_inventory()
		else: open_inventory()

func open_inventory():
	get_parent().visible = true
	get_parent().current_tab = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_inventory():
	get_viewport().gui_cancel_drag()
	get_parent().visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if external_grid.inventory: external_grid.set_inventory(null)

func add_inventory(inventory:Inventory):
	inventory_grids.append($InventoryContainer.add_container(inventory))

func remove_inventory(inventory:Inventory):
	for grid in inventory_grids:
		if grid.inventory == inventory:
			inventory_grids.erase(grid)
			grid.queue_free()

func open_container_inventory(inventory:Inventory):
	external_grid.set_inventory(inventory)
	open_inventory()
	external_grid._update()
