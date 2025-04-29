@tool
extends Node
class_name ItemPrefab

@onready var folder = "res://items/"
@export var data : ItemData
@export_tool_button("Start packing process") var start_packing_action = start_packing
@export_tool_button("Reload") var reload_action = reload
@export_tool_button("Save") var save_action = save

func _ready() -> void:
	if Engine.is_editor_hint():
		reload()

func pick_up() -> ItemData:
	return data

func start_packing():
	var item_data_list = []
	var dir = DirAccess.open(folder+"/data")
	if dir:
		for file in dir.get_files():
			var file_name = file.split(".",false,1)
			if file_name[1] == "tres":
				item_data_list.append(load(folder+"/data/"+file_name[0]+".tres"))
	for item in item_data_list:
		data = item
		reload()
		save()



func reload():
	if not data: return
	for child in get_children():
		remove_child(child)
	var child = RigidBody3D.new()
	child.name = data.name
	child.script = load("res://items/Item.gd")
	self.add_child(child)
	child.owner = self
	child.data = data
	child.set_collision_layer_value(1, false)
	child.set_collision_layer_value(3, true)
	child.set_collision_mask_value(1, true)
	child.set_collision_mask_value(2, true)
	child.set_collision_mask_value(3, true)
	child.set_collision_mask_value(4, true)
	child.set_collision_mask_value(9, true)
	var mesh = MeshInstance3D.new()
	mesh.mesh = data.mesh
	mesh.name = "mesh"
	add_child(mesh)
	mesh.owner = self
	mesh.reparent(child)
	mesh.create_convex_collision()
	mesh.get_child(0).get_child(0).reparent(child)
	mesh.get_child(0).queue_free()

func save():
	var node_to_save = find_child(data.name)
	if node_to_save == null: return
	var scene = PackedScene.new()
	for child in node_to_save.get_children():
		child.set_owner(node_to_save)
	scene.pack(node_to_save)
	ResourceSaver.save(scene, folder+data.name+".tscn")
