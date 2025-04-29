extends Resource
class_name ItemData

enum ItemType {Axe,Pickaxe,Shovel,Sword}
enum EquipmentSlot { NONE, HEAD, CHEST, LEGS, PRIMARY, SECONDARY}
enum UseFunction { NONE, EQUIP}

@export var name : String
@export var id : int = 0
@export var icon : Texture2D
@export var mesh : Mesh
@export var width : int
@export var height : int
@export var is_equippable : bool = false
@export var equipment_slot : EquipmentSlot = EquipmentSlot.NONE
@export var is_stackable : bool = false
@export var max_stack : int = 1
@export var quantity : int = 1
@export var use : UseFunction = UseFunction.NONE
@export var stat_bonus : Dictionary = {}
