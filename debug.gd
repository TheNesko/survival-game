extends Control

enum Message {NORMAL, WARNING, ERROR}
@onready var console_input = $ConsolePanel/Container/ConsoleInput
@onready var popup = $ConsolePanel/Container/ConsoleInput/popup
var console_input_commands = []
var suggested_commands = []
var current_suggested = 0

var debuging : bool = true
@onready var message_box = $ConsolePanel/Container/Message

func _ready() -> void:
	visible = false
	display_if_debuging()
	console_input.text_changed.connect(_show_suggested_commands)

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
	if Input.is_key_pressed(KEY_UP) and len(console_input_commands) > 0:
		console_input.set_text(console_input_commands[len(console_input_commands)-1])
		console_input.set_caret_column(1000)
		console_input.text_changed.emit()
	if Input.is_key_pressed(KEY_TAB) and len(suggested_commands) >= 1:
		_insert_suggested_command()

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
			return ItemStorage.get_item(int(arg))
		_:
			return str_to_var(arg)

func launch_command(command_name:String,values):
	var command = null
	for method in DebugCommands.commands:
		if method.name == command_name:
			command = method
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

func _suggest_command(text):
	if text == "": return []
	var suggested = []
	for command in DebugCommands.commands:
		if text in command.name:
			suggested.append(command)
	return suggested

func _show_suggested_commands(text):
	popup.visible = false
	popup.text = ""
	current_suggested = 0
	suggested_commands = []
	if text == "": return
	var command_name = text.split(" ")[0]
	var commands = _suggest_command(command_name)
	if commands == []: return
	if len(commands) > 1:
		for command in commands:
			var suggestion = command.name
			popup.add_text(suggestion+"\n")
			suggested_commands.append(suggestion)
	else:
		var command = commands[0]
		var suggestion = command.name+"  "
		for arg in command.args:
			var type_name = arg.class_name
			if arg.class_name ==  "":
				type_name = type_string(arg.type)
			suggestion += arg.name + ":" + type_name + "  "
		popup.add_text(suggestion)
		suggested_commands.append(suggestion)
	popup.size.x = popup.get_content_width()+40
	popup.size.y = popup.get_content_height()+20
	popup.position.y = console_input.size.y
	popup.position.x = 15
	popup.visible = true

func _insert_suggested_command():
	var text_len = len(console_input.text.split(" ",false))
	if len(suggested_commands)-1 < current_suggested: current_suggested = 0
	var split_command = suggested_commands[current_suggested].split(" ",false)
	if text_len == 1:
		console_input.set_text(split_command[0])
	else:
		pass
		#for x in range(text_len-1,len(split_command)):
			#prints(x,split_command[x])
	current_suggested += 1
	console_input.set_caret_column(1000)
