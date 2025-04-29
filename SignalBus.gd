extends Node

# Inventory Signals
signal item_added(slot)
signal item_removed(slot)
signal item_drop(slot)

signal item_equip(slot)
signal item_unequip(slot)
signal item_swap(slot_1,slot_2)
# Equipment Signals
signal equipment_changed(slot)
signal update_slots
# ====================
