extends StaticBody3D
class_name ResourceClass

@export var stats : StatisticsComponent
@export var resource_drop : Item
@export var resource_quantity : int

func drop_resources():
	var item = ItemStorage._get_item(resource_drop.id).scene
	var world = get_parent()
	for x in range(resource_quantity):
		var new_item = item.instantiate()
		new_item.position = position
		world.add_child(new_item)
	
