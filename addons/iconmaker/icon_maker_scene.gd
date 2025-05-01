@tool
extends Control

var icon_folder = ""
var current_item : Item
var icon_scale = 1
var cell_size = 64
var width = 1
var height = 1
var mesh_pos = Vector3.ZERO
var mesh_rotation = Vector3.ZERO

@onready var mesh = %Mesh
@onready var texture_rect = %TextureRect
@onready var viewport = %SubViewport
@onready var icon_folder_select = %IconFolderSelect
@onready var item_select = %ItemSelect


func _physics_process(delta: float) -> void:
	texture_rect.size = Vector2(width*cell_size,height*cell_size)
	viewport.size = Vector2(width*cell_size*icon_scale,height*cell_size*icon_scale)
	texture_rect.texture = viewport.get_texture()
	mesh.position = mesh_pos
	mesh.rotation = mesh_rotation
	

func _on_width_edit_value_changed(value: float) -> void:
	width = value
	viewport.size.x = width * icon_scale

func _on_height_edit_value_changed(value: float) -> void:
	height = value
	viewport.size.y = height * icon_scale

func _on_scale_edit_value_changed(value: float) -> void:
	icon_scale = value
	viewport.size = Vector2(width*icon_scale,height*icon_scale)

func _on_icon_folder_pressed() -> void:
	icon_folder_select.popup()


func _on_icon_folder_select_dir_selected(dir: String) -> void:
	icon_folder = dir+"/"


func _on_x_pos_value_changed(value: float) -> void:
	mesh_pos.x = value


func _on_y_pos_value_changed(value: float) -> void:
	mesh_pos.y = value


func _on_z_pos_value_changed(value: float) -> void:
	mesh_pos.z = value


func _on_item_folder_pressed() -> void:
	item_select.popup()


func _on_item_select_file_selected(path: String) -> void:
	current_item = load(path)
	if not current_item: return
	mesh.mesh = current_item.mesh


func _on_create_pressed() -> void:
	if icon_folder == "": 
		icon_folder_select.popup()
		return
	await RenderingServer.frame_post_draw
	var file_name = current_item.name + ".png"
	var dir = DirAccess.open(icon_folder)
	if FileAccess.file_exists(icon_folder + file_name):
		dir.remove(file_name)
	
	var img = viewport.get_texture().get_image()
	img.convert(img.FORMAT_RGBA8)
	
	var w = img.get_width()
	var h = img.get_height()
	for y in range(h):
		for x in range(w):
			var col = img.get_pixel(x, y)
			col.a = 1
			if col.g >= 1 and col.r == 0 and col.b == 0:
				col.g = 0
				col.a = 0
			img.set_pixel(x, y, col)
	
	img.save_png(icon_folder+file_name)
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_resource_filesystem().update_file(icon_folder+file_name)


func _on_x_rot_value_changed(value: float) -> void:
	mesh_rotation.x = value


func _on_y_rot_value_changed(value: float) -> void:
	mesh_rotation.y = value


func _on_z_rot_value_changed(value: float) -> void:
	mesh_rotation.z = value


func _on_cell_size_edit_value_changed(value: float) -> void:
	cell_size = value
