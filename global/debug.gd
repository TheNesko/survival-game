extends Control

signal caret_column_changed

enum Message {NORMAL, WARNING, ERROR}

var console_input_commands = []
var suggested_commands = []
var current_suggested = 0
var debuging : bool = true
var _previous_caret_column = 0

@onready var console_input = $ConsolePanel/Container/ConsoleInput
@onready var popup = $ConsolePanel/Container/ConsoleInput/popup
@onready var message_box = $ConsolePanel/Container/Message

func _ready() -> void:
	visible = false
	display_if_debuging()
	console_input.text_changed.connect(_text_changed)
	console_input.text_submitted.connect(_text_changed)
	caret_column_changed.connect(_caret_column_changed)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		debuging = !debuging
		display_if_debuging()
	if Input.is_action_just_pressed("debug_console"):
		visible = not visible
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			console_input.grab_focus()
			console_input.edit()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_key_pressed(KEY_UP):
		if $ConsolePanel/Container/ConsoleInput/popup.visible:
			_change_selected_suggestion(false)
		elif len(console_input_commands) > 0:
			_set_console_text(console_input_commands[len(console_input_commands)-1])
	if Input.is_key_pressed(KEY_DOWN):
		_change_selected_suggestion(true)
	if Input.is_key_pressed(KEY_TAB) and len(suggested_commands) >= 1:
		_insert_suggested_command()
	if console_input.get_caret_column() != _previous_caret_column:
		caret_column_changed.emit()

func send_message(text: String="",type:Message=Message.NORMAL):
	var line_color = "[color=grey]"
	if type == Message.WARNING: line_color = "[color=yellow]"
	elif type == Message.ERROR: line_color = "[color=red]"
	text = ">" + line_color + text + "[/color]\n"
	message_box.append_text(text)

func display_if_debuging():
	if debuging: send_message("Debuging is turned on",Message.ERROR)
	else: send_message("Stopped debuging",Message.ERROR)

func convert_arg(arg,target_type):
	var item_data_type : int = typeof(ItemData)
	match target_type:
		TYPE_STRING:
			return arg
		item_data_type:
			return ItemStorage._get_item(int(arg))
		_:
			return str_to_var(arg)

func launch_command(command_name:String,values):
	var command = DebugCommands._get_command(command_name)
	if command == null:
		send_message("Couldn't find command: "+command_name)
		return false
	var arg_count = len(command.args)
	values = values.split(" ",false)
	if arg_count > len(values):
		send_message("Not enough arguments!",Message.WARNING)
		return false
	if arg_count < len(values):
		send_message("Too many arguments!",Message.WARNING)
		return false
	var arguments = []
	for arg in range(len(command.args)):
		var arg_type = command.args[arg].type
		var new_value = convert_arg(values[arg],arg_type)
		if typeof(new_value) != arg_type:
			var error_message = "Passed wrong argument " + command.args[arg].name
			error_message += " of type " + type_string(typeof(new_value))
			error_message += " but " + type_string(arg_type) + " was expected"
			send_message(error_message,Message.WARNING)
			return false
		arguments.append(new_value)
	command.parent.callv(command.name,arguments)
	return true

func _on_console_input_text_submitted(text: String) -> void:
	console_input.text = ""
	console_input_commands.append(text)
	var formated_text = text.split(" ",false,1)
	if len(formated_text) <= 0: return
	var command = formated_text[0].to_lower()
	var values = formated_text[1] if len(formated_text) > 1 else ""
	launch_command(command,values)
	current_suggested = 0

func _get_string_size(text:String,ui_element):
	var font = ui_element.get_theme_font("font")
	var font_size = ui_element.get_theme_font_size("font_size")
	var string_size = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
	return string_size

func _get_caret_position(ui):
	var text = ui.text.left(ui.get_caret_column())
	var pos = _get_string_size(text,ui)
	return pos

func _suggest_commands(text):
	popup.text = ""
	suggested_commands = []
	if text == "": return
	var command_name = text.split(" ")[0]
	if _current_edited_argument() > 0:
		if DebugCommands._get_command(command_name) == null: return
	var commands = []
	for command in DebugCommands.commands:
		if command.name.left(len(command_name)) != command_name: continue
		commands.append(command)
	if commands == []: return
	for command in commands:
		var suggestion = command.name+"  "
		for arg in command.args:
			var type_name = arg.class_name
			if arg.class_name ==  "":
				type_name = type_string(arg.type)
			suggestion += arg.name
			if type_name != type_string(TYPE_NIL):
				suggestion += ":" + type_name
			suggestion += "  "
		suggested_commands.append({"command":command,"suggestion":suggestion})

func _current_edited_argument():
	var current = 0
	var text = console_input.text.left(console_input.get_caret_column())
	for index in range(len(text)):
		if index == 0 and text[index] == " ": continue
		if text[index] == " " and text[index-1] != " ":
			current += 1
	return current

func _update_popup():
	popup.visible = false
	popup.text = ""
	var text = ""
	var current_argument = _current_edited_argument()
	for index in range(len(suggested_commands)):
		var command_text = suggested_commands[index].suggestion
		var suggestions = command_text.split(" ",false)
		if len(suggestions)-1 < current_argument: break
		var suggestion = suggestions[current_argument]
		# if more than one suggestion and suggested command is selected
		# add > character to the suggestion text to indicate that it is selected
		if len(suggested_commands)-1 > 1 and index == current_suggested:
			text += ">" + suggestion
		else: text += suggestion
		text += "\n"
	if text.is_empty():
		popup.visible = false
		return
	popup.add_text(text)
	popup.size.x = popup.get_content_width()+40
	popup.size.y = popup.get_content_height()+20
	popup.position.y = console_input.size.y
	popup.position.x = _get_caret_position(console_input).x
	popup.visible = true

func _change_selected_suggestion(dir:bool):
	if dir: #go down
		current_suggested += 1
		if current_suggested > len(suggested_commands)-1: current_suggested = 0
	else: #go up
		current_suggested -= 1
		if current_suggested < 0: current_suggested = len(suggested_commands)-1
	_update_popup()

func _insert_suggested_command():
	var text = console_input.text
	var formated_text = text.split(" ",false)
	var currently_editing = _current_edited_argument()
	if len(suggested_commands)-1 < current_suggested: current_suggested = 0
	var command = suggested_commands[current_suggested].command
	if currently_editing == 0:
		text = text.replace(formated_text[0],command.name+" ")
	elif currently_editing > 0:
		# TODO
		# DO I EVEN WANT TO DO THAT?
		if currently_editing <= len(command.args):
			var arg = command.args[currently_editing-1]
			var arguments = _suggest_command_argument_values(arg.type)
	_set_console_text(text)

func _suggest_command_argument_values(type:int):
	# TODO suggest command arguments
	var item_data_type = typeof(ItemData)
	match type:
		item_data_type:
			pass
		_:
			return null

func _text_changed(_text):
	current_suggested = 0
	_suggest_commands(console_input.text)
	_update_popup()

func _caret_column_changed():
	_update_popup()

func _set_console_text(text):
	console_input.set_text(text)
	console_input.set_caret_column(1000)
	console_input.text_changed.emit(console_input.text)
