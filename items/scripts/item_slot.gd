extends TextureButton
class_name ItemSlot

@export var item : ItemData = null
var equipped : bool = false
var quantity : int = 0

func _ready() -> void:
	update()

func is_empty():
	return item == null

func update():
	$equipped.visible = true if equipped == true and item != null else false
	$Label.text = ""
	if item == null:
		texture_normal = Texture2D.new()
		return
	if item.is_stackable:
		$Label.text = String.num_int64(quantity)
	texture_normal = item.icon

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			if equipped:
				SignalBus.item_unequip.emit(self)
			SignalBus.item_drop.emit(self)
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if equipped: SignalBus.item_unequip.emit(self)
			else: SignalBus.item_equip.emit(self)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null: return false
	var data = {
		"origin_slot":self,
		"target_slot":self
	}
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture_normal
	drag_texture.size = Vector2(100,100)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
	set_drag_preview(control)
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not Dictionary: return false
	var target_slot = self
	if target_slot is TextureButton:
		data["target_slot"] = target_slot
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var temp_item = data["origin_slot"].item
	var target_slot = data["target_slot"]
	var origin_slot = data["origin_slot"]
	if origin_slot == target_slot: return
	SignalBus.item_swap.emit(target_slot,origin_slot)
