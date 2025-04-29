extends Node

var equipped: Dictionary = {
	ItemData.EquipmentSlot.HEAD: null,
	ItemData.EquipmentSlot.CHEST: null,
	ItemData.EquipmentSlot.LEGS: null,
	ItemData.EquipmentSlot.PRIMARY: null,
	ItemData.EquipmentSlot.SECONDARY: null,
}

func _ready() -> void:
	SignalBus.item_equip.connect(equip_item)
	SignalBus.item_unequip.connect(unequip_item)

func _physics_process(_delta: float) -> void:
	if DEBUG.debuging:
		pass

func equip_item(slot) -> bool:
	var item = slot.item
	if item == null: return false
	var equipment_slot = item.equipment_slot
	if not item.is_equippable:
		return false
	var old_slot
	if equipped[equipment_slot] != null:
		old_slot = equipped[equipment_slot]
		old_slot.equipped = false
		SignalBus.equipment_changed.emit(old_slot)
	equipped[equipment_slot] = slot
	slot.equipped = true
	SignalBus.equipment_changed.emit(slot)
	return true

func unequip_item(slot):
	var item = slot.item
	if item == null: return false
	equipped[item.equipment_slot] = null
	slot.equipped = false
	SignalBus.equipment_changed.emit(slot)
	return true
