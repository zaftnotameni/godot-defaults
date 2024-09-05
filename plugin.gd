@tool
extends EditorPlugin

func _enter_tree() -> void:
	print_verbose('=> activating defaults')
	print_verbose('=> setting up project metadata')
	await setup_default_project_metadata()
	print_verbose('=> setup up project metadata')
	print_verbose('=> setting up project settings')
	setup_default_project_settings()
	print_verbose('=> setup up project settings')
	print_verbose('=> setting up input actions')
	setup_default_input_actions()
	print_verbose('=> setup up input actions')
	print_verbose('=> activated defaults')

func _exit_tree() -> void:
	print_verbose('=> deactivated defaults')

static func tree() -> SceneTree: return Engine.get_main_loop()

static var pallete_colors := []

func setup_default_project_metadata():
	var pallete_file_path = 'res://addons/defaults/palette.hex'
	var project_metadata_file_path := 'res://.godot/editor/project_metadata.cfg'
	var hex_file_url := [
		'https://lospec.com/palette-list/purplemorning8.hex',
		'https://lospec.com/palette-list/vaporcraze-8.hex',
		'https://lospec.com/palette-list/cold-war-8.hex',
		'https://lospec.com/palette-list/not-a-bauhaus-a-bauhome.hex',
		'https://lospec.com/palette-list/st-8-phoenix.hex',
		'https://lospec.com/palette-list/eight-hues-of-toxic-ooze.hex',
	][-1] as String

	if not FileAccess.file_exists(pallete_file_path):
		print_verbose('downloading: ' + hex_file_url)
		var http_request := HTTPRequest.new()
		http_request.download_file = pallete_file_path
		add_child(http_request)
		await http_request.ready
		print_verbose('downloading: ' + hex_file_url)
		http_request.request(hex_file_url)
		http_request.request_completed.connect(func(res, status, headers, body:PackedByteArray): printt(res, status, headers, body))
		await http_request.request_completed
		http_request.queue_free()

	var fa := FileAccess.open(pallete_file_path, FileAccess.READ)
	var lines := fa.get_as_text().split('\n')
	fa.close()
	for line:String in lines:
		if not line or line.is_empty(): continue
		pallete_colors.push_back(Color('#' + line.strip_edges()))

	pallete_colors.sort_custom(func (a:Color, b:Color): return a.get_luminance() < b.get_luminance())

	var editor_settings := EditorInterface.get_editor_settings()
	var preset_colors := editor_settings.get_project_metadata('color_picker', 'presets', PackedColorArray([])) as PackedColorArray
	var colors_to_add := []
	var preset_colors_as_html := []
	for color in preset_colors:
		preset_colors_as_html.push_back(color.to_html())
	for color in pallete_colors:
		if preset_colors_as_html.has(color.to_html()): continue
		colors_to_add.push_back(color)
	for color in colors_to_add:
		preset_colors.push_back(color)
	if colors_to_add.is_empty(): return
	printt('colors to add', colors_to_add.map(func (c): return c.to_html()))
	editor_settings.set_project_metadata('color_picker', 'presets', preset_colors)

func setup_default_project_settings():
	pass

func setup_default_input_actions():
	pass
