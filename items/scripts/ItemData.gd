class_name Item
extends Resource


@export_category("General")
@export var name : String
@export var id : int = 0
@export var icon : Texture2D
@export var mesh : Mesh
@export_category("Inventory")
@export var columns : int = 1
@export var rows : int = 1
@export var origin : Vector2 = Vector2.ZERO
@export var rotated : bool = false
@export var is_stackable : bool = false
@export var max_stack : int = 1
@export var quantity : int = 1
@export_category("Stat Bonus")
@export var stat_bonus : Dictionary = {}
