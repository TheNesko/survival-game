class_name PickUp
extends Entity

@export var data : Item

func _ready() -> void:
	name = data.name

func pick_up() -> Item:
	return data
