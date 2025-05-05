class_name EquipmentItem
extends Item


@export var equipment_slot : Equipment.Slots = Equipment.Slots.Primary


func use():
	print("used equipment")
