@tool
extends EditorPlugin

func _enter_tree() -> void:
	print_verbose('=> activating defaults')

func _exit_tree() -> void:
	print_verbose('=> deactivating defaults')
