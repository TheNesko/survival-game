extends RigidBody3D
class_name PickUp

@export var data : Item

func _ready() -> void:
	name = data.name

func pick_up() -> Item:
	return data
