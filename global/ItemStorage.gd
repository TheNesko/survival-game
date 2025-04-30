extends Node

var items_folder = "res://items"
var items = {}

func _ready() -> void:
	_load_data()
	_load_scenes()

func _load_data():
	var item_files = []
	var folder = DirAccess.open(items_folder+"/data")
	if folder:
		for file in folder.get_files():
			var file_name = file.split(".",false,1)
			if "tres" in file_name[1]:
				if ".remap" in file_name[1]:
					file = file.replace(".remap","")
				item_files.append(file)
	for item in range(len(item_files)):
		var new_item = load(items_folder+"/data/"+item_files[item])
		new_item.id = item
		items[item] = {"data":null,"scene":null}
		items[item]["data"] = new_item

func _load_scenes():
	var item_files = []
	var folder = DirAccess.open(items_folder+"/scenes")
	if folder:
		for file in folder.get_files():
			var file_name = file.split(".",false,1)
			if "tscn" in file_name[1]:
				if ".remap" in file_name[1]:
					file = file.replace(".remap","")
				item_files.append(file)
	for item in range(len(item_files)):
		var new_item = load(items_folder+"/scenes/"+item_files[item])
		items[item]["scene"] = new_item
	

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
		if new_item.data == null: return
		new_item.position = Vector3(x,y,z)
		world.add_child(new_item)
	DEBUG.send_message("Spawned "+str(quantity)+" "+items[item_id].data.name)
