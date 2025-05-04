@tool
class_name ItemCreator
extends Node

@export_dir var items_folder : String
var item_paths = []
@export_tool_button("Make item") var make_action = _make

func _make():
	var dir = DirAccess.open(items_folder)
	if not dir: return
	_get_files_in_folder(dir.get_current_dir())
	for path in item_paths:
		var item_dir = DirAccess.open(path)
		for file in item_dir.get_files():
			if file.ends_with(".tres"):
				_pack(load(path+"/"+file),path)
	EditorInterface.get_resource_filesystem().scan()

func _get_files_in_folder(folder):
	var dir = DirAccess.open(folder)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_get_files_in_folder(dir.get_current_dir()+"/"+file_name)
		else:
			if file_name.ends_with(".tres"):
				item_paths.append(dir.get_current_dir())
		file_name = dir.get_next()

func has_scene(folder):
	var dir = DirAccess.open(folder)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			return true
		file_name = dir.get_next()
	return false

func _pack(data:Item,folder):
	if not data: return
	if has_scene(folder): return
	for child in get_children():
		remove_child(child)
	var child = RigidBody3D.new()
	child.name = data.name
	child.script = load("res://items/Scripts/Item.gd")
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
	_save(data,folder)

func _add_child(child,parent):
	add_child(child)
	child.owner = self
	child.reparent(parent)

func _save(data:Item,folder):
	var node_to_save = find_child(data.name)
	if node_to_save == null: return
	var scene = PackedScene.new()
	for child in node_to_save.get_children():
		child.set_owner(node_to_save)
	scene.pack(node_to_save)
	var dir = DirAccess.open(folder)
	if not dir: return
	ResourceSaver.save(scene, folder+"/"+data.name+".tscn")
