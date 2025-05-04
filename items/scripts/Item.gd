class_name PickUp
extends Entity

@export var data : Item

func _ready() -> void:
	if not data:
		DEBUG.send_message(name+" has no item data",DEBUG.Message.ERROR)
		return
	name = data.name

func pick_up() -> Item:
	return data
