@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = load("res://addons/OpenAI/dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock)
	dock.find_child("Reload").connect("pressed", self.reload)

func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()

func reload():
	print("Reloading OpenAI")
	_exit_tree()
	_enter_tree()
