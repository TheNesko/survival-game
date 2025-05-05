class_name Equipment
extends Node

signal item_equipped(item:EquipmentItem)
signal item_unequipped(item:EquipmentItem)
signal item_removed(item:EquipmentItem)

enum Slots {
	Primary,
	Secondary,
	Head,
	Body,
	Legs,
	Feet,
	Arms,
	Hands,
	Back
}

var equipped : Array[EquipmentItem] = []


func _ready() -> void:
	SignalManager.item_pickup.connect(pickup_item)

func pickup_item(item_pickup:PickUp) -> void:
	var item = item_pickup.pick_up().deep_duplicate()
	# go through all the containers/inventories to check if item can be picked up
	if item is EquipmentItem:
		var equipment_slots = get_tree().get_nodes_in_group("EquipmentSlot")
		for slot in equipment_slots:
			if not slot.item and item.equipment_slot == slot.type:
				equip_item(item,slot)
				item_pickup.queue_free()
				return
	if equipped.is_empty(): return
	for equipment in equipped:
		if equipment is ContainerItem:
			var inventory = equipment.inventory
			if inventory.add_item(item):
				item_pickup.queue_free()
				break

func equip_item(item:EquipmentItem,slot:EquipmentSlot) -> bool:
	slot.item = item
	equipped.append(item)
	if item.has_method('equip'):
		item.equip()
	item_equipped.emit(item)
	return true

func unequip_item(item:EquipmentItem,slot:EquipmentSlot) -> bool:
	if not item in equipped: return false
	if item.has_method('unequip'):
		item.unequip()
	equipped.erase(item)
	slot.item = null
	item_unequipped.emit(item)
	return true

func remove_item(item:EquipmentItem) -> bool:
	if not item in equipped: return false
	if item.has_method('unequip'):
		item.unequip()
	equipped.erase(item)
	item_unequipped.emit(item)
	return true

func drop_item(item:EquipmentItem,slot:EquipmentSlot) -> void:
	ItemStorage._drop_item(item,item.quantity)
	slot.item = null
	remove_item(item)
