extends Control



@onready var parent = get_parent()
@onready var cursor = $cursor
@onready var target_name = $target_name
@onready var inventory_panel : InventoryPanel = %InventoryPanel
@onready var World_inventory_panel : InventoryPanel = %WorldInventoryPanel
@onready var inventory : Inventory = %Inventory

func _physics_process(_delta: float) -> void:
	cursor.color = Color(1,1,1)
	target_name.text = ""
	if parent.interaction_target != null:
		cursor.color = Color(1,0,0)
		target_name.text = parent.interaction_target.name

func _unhandled_input(event: InputEvent) -> void:
	if DEBUG.visible: return
	if Input.is_action_just_released("inventory"):
		if not inventory_panel.is_opened:
			inventory_panel.open(inventory)
		else: 
			inventory_panel.close()
			World_inventory_panel.close()
	if Input.is_action_just_pressed("interact"):
		var interaction = parent.interaction_target
		if not interaction: return
		if interaction.has_method("interact"):
			World_inventory_panel.open(interaction.interact())
			inventory_panel.open(inventory)
	if Input.is_action_just_pressed("hotbar_1"):
		var item: Item = ItemStorage._get_item(0).data
		inventory.add_item(item)
	if Input.is_action_just_pressed("hotbar_2"):
		var item: Item = ItemStorage._get_item(1).data
		inventory.add_item(item)
	if Input.is_action_just_pressed("hotbar_3"):
		var item: Item = ItemStorage._get_item(2).data
		inventory.add_item(item)
	if Input.is_action_just_pressed("hotbar_4"):
		var item: Item = ItemStorage._get_item(3).data
		inventory.add_item(item)
	if Input.is_action_just_pressed("hotbar_5"):
		var item: Item = ItemStorage._get_item(4).data
		inventory.add_item(item)
