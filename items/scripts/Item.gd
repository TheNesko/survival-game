extends RigidBody3D
class_name Item

@export var data : ItemData

func _ready() -> void:
	name = data.name

func pick_up() -> ItemData:
	return data
