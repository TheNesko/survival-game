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

func show_commands():
	for command in commands:
		var args = command.args
		var text = ""
		for arg in args:
			text += arg.class_name +" "
		DEBUG.send_message(command.name+" "+text)

func clear(i:Array):
	DEBUG.message_box.text = ""
	print(i)

func _find_entity(entity_name:String):
	var entity = get_tree().root.find_child(entity_name,true,false)
	if not entity:
		DEBUG.send_message("Entity " + entity_name + " not found",DEBUG.Message.WARNING)
		return null
	return entity

func teleport(entity_name:String,position:Array):
	var entity = _find_entity(entity_name) 
	if not entity: return
	entity.position.x = position[0]
	entity.position.y = position[1]
	entity.position.z = position[2]
	DEBUG.send_message("Teleported "+entity_name+" to "+var_to_str(position))

func position(entity_name:String):
	var entity = _find_entity(entity_name)
	if not entity: return
	
	DEBUG.send_message(var_to_str(entity.position))
