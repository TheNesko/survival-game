@tool
class_name ItemCreator
extends Node

@onready var folder = "res://items/"
@export var data : Item
@export_tool_button("Start packing process") var start_packing_action = _start_packing
@export_tool_button("Make item") var make_action = _make
@export_tool_button("Save") var save_action = _save

func _start_packing():
	var item_data_list = []
	var dir = DirAccess.open(folder+"/data")
	if dir:
		for file in dir.get_files():
			var file_name = file.split(".",false,1)
			if file_name[1] == "tres":
				item_data_list.append(load(folder+"/data/"+file_name[0]+".tres"))
	for item in item_data_list:
		data = item
		_make()
		_save()

func _make():
	if not data: return
	for child in get_children():
		remove_child(child)
	var child = RigidBody3D.new()
	child.name = data.name
	child.script = load("res://items/scripts/Item.gd")
	_add_child(child,self)
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
	_add_child(mesh,child)
	mesh.create_convex_collision()
	mesh.get_child(0).get_child(0).reparent(child)
	mesh.get_child(0).queue_free()

func _add_child(child,parent):
	add_child(child)
	child.owner = self
	child.reparent(parent)

func _save():
	var node_to_save = find_child(data.name)
	if node_to_save == null: return
	var scene = PackedScene.new()
	for child in node_to_save.get_children():
		child.set_owner(node_to_save)
	scene.pack(node_to_save)
	ResourceSaver.save(scene, folder+data.name+".tscn")
