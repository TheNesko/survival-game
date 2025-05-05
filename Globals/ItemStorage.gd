extends Node

var items_folder = "res://items"
var items = []

func _ready() -> void:
	_load_items()

func _load_items():
	var dir = DirAccess.open(items_folder)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_get_files_in_folder(dir.get_current_dir()+"/"+file_name)
		file_name = dir.get_next()
	for item_id in items.size():
		items[item_id].data.id = item_id

func _get_files_in_folder(folder):
	var dir = DirAccess.open(folder)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_get_files_in_folder(dir.get_current_dir()+"/"+file_name)
		else:
			var item = {"data":null,"scene":null}
			file_name.replace(".remap","")
			if file_name.ends_with(".tres"):
				file_name = file_name.split(".",false,1)
				var item_folder = dir.get_current_dir()+"/"
				item.data = load(item_folder+file_name[0]+".tres")
				item.scene = load(item_folder+file_name[0]+".tscn")
				items.append(item)
				item.data._ready()
		file_name = dir.get_next()


func _item_exist(item_id):
	if item_id > len(items)-1:
		DEBUG.send_message("Item does not exist",DEBUG.Message.WARNING)
		return false
	return true

func _get_item(item_id):
	if not _item_exist(item_id): return null
	var item = items[item_id]
	if item == null: DEBUG.send_message("Item not found",DEBUG.Message.WARNING)
	return item

func spawn_item(item_id:int,quantity:int,x:int,y:int,z:int):
	if quantity <= 0:
		DEBUG.send_message("Quantity can't be less than 1",DEBUG.Message.WARNING)
		return
	var item = _get_item(item_id)
	var world = get_tree().root
	for q in range(quantity):
		var new_item = item.scene.instantiate()
		new_item.data = item.data.duplicate()
		if new_item.data == null: return
		new_item.position = Vector3(x,y,z)
		world.add_child(new_item)
		await get_tree().create_timer(0.01).timeout
	DEBUG.send_message("Spawned "+str(quantity)+" "+items[item_id].data.name)

func _drop_item(item:Item,quantity:int=1):
	var player = get_tree().get_first_node_in_group("Player")
	var world = player.get_parent()
	var item_scene = _get_item(item.id).scene
	for q in range(quantity):
		var new_item = item_scene.instantiate()
		new_item.data = item
		if new_item.data == null: return
		new_item.position = player.global_position
		world.add_child(new_item)
		await get_tree().create_timer(0.01).timeout
