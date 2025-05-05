class_name EquipmentSlot
extends TextureRect

@export var item : Item = null
@export var type : Equipment.Slots = Equipment.Slots.Primary

var _can_drop : bool = false
var _drag_data : Dictionary

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_to_group("EquipmentSlot")
	var equipment = get_tree().get_first_node_in_group("Equipment") as Equipment
	equipment.item_equipped.connect(display)
	equipment.item_unequipped.connect(display)
	equipment.item_removed.connect(display)

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("secondary") and item:
		var equipment : Equipment = get_tree().get_first_node_in_group("Equipment")
		equipment.drop_item(item,self)

func _physics_process(delta: float) -> void:
	queue_redraw()

func display(_item=null):
	texture = null
	if not item: return
	texture = item.icon

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful() and _drag_data:
				var equipment = get_tree().get_first_node_in_group("Equipment") as Equipment
				var _item : Item = _drag_data.original_item
				if _drag_data.target is EquipmentSlot:
					equipment.remove_item(_item)
				else: _drag_data.target.inventory.remove_item(_item)
				if _drag_data.origin == self:
					if not equipment.equip_item(_item,self):
						ItemStorage._drop_item(_item,_item.quantity)
			_drag_data = {}
			queue_redraw()

func _set_drag_preview(data):
	var preview_texture = TextureRect.new()
	var preview = Control.new()
	if not data: return
	preview_texture.texture = data.item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = data.item.get_dimensions(64)
	preview.rotation_degrees = data.item.rotation
	preview_texture.position -= Vector2(32,32)
	preview.add_child(preview_texture)
	set_drag_preview(preview)

func _get_drag_data(at_position: Vector2) -> Variant:
	if not item: return
	if item is ContainerItem:
		item.inventory.drop_all_items()
	var data = {"item":item.deep_duplicate(),
			"original_item":item,
			"origin":self,
			"target":self}
	var equipment = get_tree().get_first_node_in_group("Equipment") as Equipment
	if not equipment.unequip_item(item,self): return null
	_set_drag_preview(data)
	return data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data: return false
	data.target = self
	_drag_data = data
	_can_drop = false
	var drag_item : Item = _drag_data.item
	if drag_item is EquipmentItem:
		if item == null and drag_item.equipment_slot == type:
			_can_drop = true 
	_set_drag_preview(data)
	return _can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Emit signal to equip item
	item = data.item
	var equipment = get_tree().get_first_node_in_group("Equipment") as Equipment
	equipment.equip_item(data.item,self)
	pass

func _draw() -> void:
	var color = Color(0,0,0)
	var rect = Rect2(Vector2.ZERO,custom_minimum_size)
	draw_rect(rect,color,false,2)
	if not _drag_data: return
	if _drag_data.target == self:
		color = Color(0.1,0.1,0.1,0.9)
		if _can_drop: draw_rect(rect,color)
		else:
			color.r = 0.5 
			draw_rect(rect,color)
		
