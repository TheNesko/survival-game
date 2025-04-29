extends Node

@onready var inventory_ui = get_parent().find_child("InventoryUI")
var slots: Array[ItemSlot] = []

func _ready() -> void:
	for itemSlot in get_tree().get_first_node_in_group("Hotbar").get_children():
		slots.append(itemSlot)
	for itemSlot in get_tree().get_first_node_in_group("Inventory").get_children():
		slots.append(itemSlot)
	SignalBus.item_drop.connect(drop_item)
	SignalBus.item_swap.connect(swap_items)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hotbar_1"):
		if slots[0].item:
			if slots[0].item.use == ItemData.UseFunction.EQUIP:
				if slots[0].equipped: SignalBus.item_unequip.emit(slots[0])
				else: SignalBus.item_equip.emit(slots[0])
	elif Input.is_action_just_pressed("hotbar_2"):
		if slots[1].item:
			if slots[1].item.use == ItemData.UseFunction.EQUIP:
				if slots[0].equipped: SignalBus.item_unequip.emit(slots[1])
				else: SignalBus.item_equip.emit(slots[1])


func add_item(item_data:ItemData) -> bool:
	var overflow = item_data.quantity
	if item_data.is_stackable:
		var slot = get_slot_with_item(item_data)
		if slot:
			if slot.quantity < item_data.max_stack:
				slot.quantity += item_data.quantity
				if slot.quantity > item_data.quantity:
					pass
				SignalBus.item_added.emit(slot)
				DEBUG.send_message("Added item "+item_data.name)
				return true
	for slot in slots:
		if slot.is_empty():
			slot.item = item_data
			slot.quantity += item_data.quantity
			SignalBus.item_added.emit(slot)
			DEBUG.send_message("Added item "+item_data.name)
			return true
	return false

func drop_item(slot:ItemSlot):
	if slot.item == null: return false
	var world = get_tree().current_scene
	var item = ItemStorage._get_item(slot.item.id).scene.instantiate()
	item.position = get_parent().position
	world.add_child(item)
	slot.quantity -= slot.item.quantity
	if slot.quantity <= 0:
		slot.item = null
	SignalBus.item_removed.emit(slot)
	return true

func swap_items(slot_1:ItemSlot,slot_2:ItemSlot):
	var temp_item_1 = slot_1.item
	var temp_item_2 = slot_2.item
	var equipped_1 = slot_1.equipped
	var equipped_2 = slot_2.equipped
	var quantity_1 = slot_1.quantity
	var quantity_2 = slot_2.quantity
	slot_1.item = temp_item_2
	slot_2.item = temp_item_1
	slot_1.quantity = quantity_2
	slot_2.quantity = quantity_1
	if slot_1.equipped:
		SignalBus.item_unequip.emit(slot_1)
	if slot_2.equipped:
		SignalBus.item_unequip.emit(slot_2)
	if equipped_1:
		SignalBus.item_equip.emit(slot_2)
	if equipped_2:
		SignalBus.item_equip.emit(slot_1)
	SignalBus.update_slots.emit()

func get_slot_with_item(item_data:ItemData,avalible_space:bool=true) -> ItemSlot:
	if not item_data: return
	for slot in slots:
		if slot.is_empty(): continue
		if slot.item == item_data and slot.quantity < item_data.max_stack:
			return slot
	return
