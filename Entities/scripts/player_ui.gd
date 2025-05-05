extends Control


var inventories : Array[Inventory] = []
var inventory_panels : Array[InventoryGrid] = []
var is_opened = false

@onready var parent = get_parent()
@onready var cursor = $cursor 
@onready var target_name = $target_name


func _physics_process(_delta: float) -> void:
	cursor.color = Color(1,1,1)
	target_name.text = ""
	if parent.interaction_target != null:
		cursor.color = Color(1,0,0)
		target_name.text = parent.interaction_target.name

func _unhandled_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	#if Input.is_action_just_released("inventory"):
		#if is_opened: close_inventory()
		#else: open_inventory()
	if Input.is_action_just_pressed("interact"):
		var interaction = parent.interaction_target
		if not interaction: return
		if interaction.has_method("interact"):
			interaction.interact()
			#open_inventory()
	#if Input.is_action_just_pressed("hotbar_1"):
		#var item: Item = ItemStorage._get_item(0).data
		#base_inventory.add_item(item)
	#if Input.is_action_just_pressed("hotbar_2"):
		#var item: Item = ItemStorage._get_item(1).data
		#base_inventory.add_item(item)
	#if Input.is_action_just_pressed("hotbar_3"):
		#var item: Item = ItemStorage._get_item(2).data
		#base_inventory.add_item(item)
	#if Input.is_action_just_pressed("hotbar_4"):
		#var item: Item = ItemStorage._get_item(3).data
		#base_inventory.add_item(item)
	#if Input.is_action_just_pressed("hotbar_5"):
		#var item: Item = ItemStorage._get_item(4).data
		#base_inventory.add_item(item)

func open_inventory():
	for inv_panel in inventory_panels:
		inv_panel.open()
	is_opened = true

func close_inventory():
	for inv_panel in inventory_panels:
		inv_panel.close()
	is_opened = false

func remove_inventory(inventory:Inventory):
	if not inventories.has(inventory): return
	var inv_container = $ScrollContainer/InventoryContainer
	for inv_grid in inventory_panels:
		if inv_grid.inventory == inventory:
			inventory_panels.erase(inv_grid)
			inv_container.remove_child(inv_grid)
			inv_grid.queue_free()
	inventories.erase(inventory)

func add_inventory(inventory:Inventory):
	if inventories.has(inventory): return
	inventories.append(inventory)
	var inv_container = $ScrollContainer/InventoryContainer
	var inv_grid = InventoryGrid.new()
	inv_grid.set_inventory(inventory)
	inv_container.add_child(inv_grid)
	inventory_panels.append(inv_grid)
