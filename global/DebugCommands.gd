extends Node

@onready var node_names = [
	"Inventory",
	"DebugCommands",
	"ItemStorage",
]
var nodes = []

var commands = []

func _ready() -> void:
	_get_nodes()

func _get_nodes():
	for node in node_names:
		nodes.append(get_tree().root.find_child(node,true,false))
	for node in nodes:
		var methods = node.get_script().get_script_method_list()
		for method in methods:
			var method_name = method["name"]
			if method_name[0] == "_": continue
			method["parent"] = node
			commands.append(method)

func _get_command_names():
	var command_names = []
	for command in commands:
		command_names.append(command.name)
	return command_names

func _get_command(command_name):
	for command in commands:
		if command.name == command_name:
			return command
	return null

func show_commands():
	for command in commands:
		var args = command.args
		var text = ""
		for arg in args:
			text += arg.class_name +" "
		DEBUG.send_message(command.name+" "+text)

func clear():
	DEBUG.message_box.text = ""

func _find_entity(entity_name:String):
	var entity = get_tree().root.find_child(entity_name,true,false)
	if not entity:
		DEBUG.send_message("Entity " + entity_name + " not found",DEBUG.Message.WARNING)
		return null
	return entity

func teleport(entity_name:String,x:int,y:int,z:int):
	var entity = _find_entity(entity_name) 
	if not entity: return
	entity.position.x = x
	entity.position.y = y
	entity.position.z = z
	var text = "Teleported "+entity_name+ " to position "
	text += "x:" + str(x) + " y:" + str(y) + " z:"  + str(z)
	DEBUG.send_message(text)

func position(entity_name:String):
	var entity = _find_entity(entity_name)
	if not entity: return
	
	DEBUG.send_message(var_to_str(entity.position))

func kill(entity_name:String):
	var entity = _find_entity(entity_name)
	if not entity: return
	entity.get_parent().remove_child(entity)
	entity.queue_free()
	DEBUG.send_message("Killed entity " + entity.name)

func looking_at():
	var camera = get_tree().root.find_child("Camera3D",true,false)
	if not camera: return
	var raycast = RayCast3D.new()
	raycast.target_position.z = -1000
	for i in range(20):
		raycast.set_collision_mask_value(i, true)
	camera.add_child(raycast)
	await get_tree().create_timer(0.1).timeout
	var entity = raycast.get_collider()
	raycast.queue_free()
	if entity == null: 
		DEBUG.send_message("Can't find entity",DEBUG.Message.WARNING)
		return
	DEBUG.send_message("Looking at " + entity.name)
