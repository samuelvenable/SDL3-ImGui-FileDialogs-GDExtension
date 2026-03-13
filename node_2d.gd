extends Node2D

func remove_empty_strings(original_array: PackedStringArray) -> PackedStringArray:
	var filtered_array := PackedStringArray()
	for text in original_array:
		if text != "" and text != "\n" and text != "\r\n":
			filtered_array.push_back(text)
	return filtered_array

func execute_and_echo_output(executable_path: String, arguments: PackedStringArray, output: Array) -> void:
	output = []
	var pid = OS.execute(executable_path, arguments, output, true)
	if pid != -1:
		remove_empty_strings(output)
		var entire_output = '\n'.join(PackedStringArray(output))
		if entire_output != "" and entire_output != "\n" and entire_output != "\r\n":
			OS.execute(executable_path, ["--show-message", entire_output], output, true)

func _ready() -> void:
	var output = []
	var executable_path
	var app_bundle_path
	var parent_directory = ""
	await get_tree().create_timer(1.0).timeout
	if OS.has_feature("editor") == true:
		parent_directory = ProjectSettings.globalize_path("res://")
	else:
		parent_directory = OS.get_executable_path().get_base_dir() + "/"
	get_window().title = "Dear ImGui File Dialogs"
	OS.set_environment("IMGUI_DIALOG_CAPTION", get_window().title)
	# Select a Custom Theme for All Dialogs 
	# Classic=-1, Dark=0, Light=1, Custom=2
	# Example themes -1 to 1 are from ImGui
	OS.set_environment("IMGUI_DIALOG_THEME", "2")
	# Set the Custom Color Theme 
	# Color Scheme (R,G,B=0,1,2) 
	OS.set_environment("IMGUI_TEXT_COLOR_0", "1")
	OS.set_environment("IMGUI_TEXT_COLOR_1", "1")
	OS.set_environment("IMGUI_TEXT_COLOR_2", "1")
	OS.set_environment("IMGUI_HEAD_COLOR_0", "0.35")
	OS.set_environment("IMGUI_HEAD_COLOR_1", "0.55")
	OS.set_environment("IMGUI_HEAD_COLOR_2", "0.55")
	OS.set_environment("IMGUI_AREA_COLOR_0", "0.18")
	OS.set_environment("IMGUI_AREA_COLOR_1", "0.18")
	OS.set_environment("IMGUI_AREA_COLOR_2", "0.18")
	OS.set_environment("IMGUI_BODY_COLOR_0", "1")
	OS.set_environment("IMGUI_BODY_COLOR_1", "1")
	OS.set_environment("IMGUI_BODY_COLOR_2", "1")
	OS.set_environment("IMGUI_POPS_COLOR_0", "0.07")
	OS.set_environment("IMGUI_POPS_COLOR_1", "0.07")
	OS.set_environment("IMGUI_POPS_COLOR_2", "0.07")
	# Show a Cancel Button in the Input Dialogs
	OS.set_environment("IMGUI_DIALOG_CANCELABLE", "1")
	# Set the Font File(s) for the Dialogs (Line-Feed "\n" Separated)
	OS.set_environment("IMGUI_FONT_FILES", parent_directory + "Roboto-Medium.ttf")
	var filter = "Supported Image Files (*.png *.gif *.jpg *.jpeg)|*.png;*.gif;*.jpg;*.jpeg|PNG Image Files (*.png)|*.png|GIF Image Files (*.gif)|*.gif|JPEG Image Files (*.jpg *.jpeg)|*.jpg;*.jpeg"
	match OS.get_name():
		"Windows":
			executable_path = parent_directory + "filedialogs.exe"	
		"macOS":
			app_bundle_path = parent_directory + "filedialogs.app"
			executable_path = parent_directory + "filedialogs.app/Contents/MacOS/filedialogs"
			OS.execute("xattr", ["-d", "-r", "com.apple.quarantine", app_bundle_path], output, true)
			OS.execute("chmod", ["u+x", executable_path], output, true)
		"Linux":
			executable_path = parent_directory + "filedialogs.AppImage"
			OS.execute("chmod", ["u+x", executable_path], output, true)
	execute_and_echo_output(executable_path, ["--show-message", "This is a dialog box. Click OK to continue."], output)
	execute_and_echo_output(executable_path, ["--show-question", "Here is a question box. Yes or no?"], output)
	execute_and_echo_output(executable_path, ["--show-question-ext", "Here is yet another question box. Yes, no, or cancel?"], output)
	execute_and_echo_output(executable_path, ["--get-open-filename-ext", filter, "Select a file", "", "Open File"], output)
	execute_and_echo_output(executable_path, ["--get-open-filenames-ext", filter, "Select one or more files", "", "Open Files"], output)
	execute_and_echo_output(executable_path, ["--get-save-filename-ext", filter, "Untitled.png", "", "Save As"], output)
	execute_and_echo_output(executable_path, ["--get-directory-alt", "Select Directory", ""], output)
	execute_and_echo_output(executable_path, ["--get-string", "Enter a string in the input box below:", "ENTER TEXT HERE"], output)
	execute_and_echo_output(executable_path, ["--get-number", "Enter a number in the input box below:", "404"], output)
	get_tree().quit()
