class_name Item
extends Resource

enum RotationAngle {
	Right = 0,
	Down = 90,
	Left = 180,
	Up = 270
}

@export_category("General")
@export var name : String
@export var id : int = 0
@export var icon : Texture2D
@export var mesh : Mesh
@export_category("Inventory")
@export var shape : Array[Vector2i] = [Vector2i.ZERO]
var origin : Vector2 = Vector2.ZERO
@export var rotation = RotationAngle.Right
@export var is_stackable : bool = false
@export var max_stack : int = 1
@export var quantity : int = 1

func _ready():
	pass

func use():
	DEBUG.send_message("Used "+name)

func deep_duplicate() -> Resource:
	var new_resource := self.duplicate(true)
	return new_resource

func rotate_clockwise() -> Array[Vector2i]:
	var rotated : Array[Vector2i]
	for cell in shape:
		rotated.append(Vector2i(-cell.y, cell.x))
	shape = rotated
	match rotation:
		RotationAngle.Right:
			rotation = RotationAngle.Down
		RotationAngle.Down:
			rotation = RotationAngle.Left
		RotationAngle.Left:
			rotation = RotationAngle.Up
		RotationAngle.Up:
			rotation = RotationAngle.Right
	return shape

func rotate_counter_clockwise() -> Array[Vector2i]:
	var rotated : Array[Vector2i]
	for cell in shape:
		rotated.append(Vector2i(cell.y, -cell.x))
	shape = rotated
	match rotation:
		RotationAngle.Right:
			rotation = RotationAngle.Up
		RotationAngle.Down:
			rotation = RotationAngle.Right
		RotationAngle.Left:
			rotation = RotationAngle.Down
		RotationAngle.Up:
			rotation = RotationAngle.Left
	return shape

func rotate_shape_clockwise(_shape:Array[Vector2i]) -> Array[Vector2i]:
	var rotated : Array[Vector2i]
	for cell in _shape:
		rotated.append(Vector2i(-cell.y, cell.x))
	return rotated

func get_original_shape() -> Array[Vector2i]:
	var rotated = shape
	var rotate_ammount = clampi(rotation / 90,0,3)
	if rotate_ammount != 0:
		while rotate_ammount != 4:
			rotated = rotate_shape_clockwise(rotated)
			rotate_ammount += 1
	return rotated

func get_dimensions(cell_size: int) -> Vector2i:
	var original_shape = get_original_shape()
	
	var min_x = original_shape[0].x
	var max_x = original_shape[0].x
	var min_y = original_shape[0].y
	var max_y = original_shape[0].y
	
	for cell in original_shape:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)
	
	var width_in_cells = max_x - min_x + 1
	var height_in_cells = max_y - min_y + 1
	
	return Vector2i(width_in_cells * cell_size, height_in_cells * cell_size)
