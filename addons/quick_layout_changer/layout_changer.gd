@tool
class_name LayoutChanger extends EditorPlugin

const LayoutPicker = preload("layout_picker.gd")
var layout_picker: LayoutPicker

func find_popup_by_name(name, node=null) -> PopupMenu:
	if node == null:
		node = get_tree().root
	for child in node.get_children():
		# FIXME: This is horribly hacky, and relies on the Layouts apparently never being localised
		# (at least to the extent I was able to test). There are probably a 1001 ways
		# in which it can break, but I don't think we can do any better with the current
		# editor API. There's nothing we can do to manipulate layouts directly, and
		# a slightly better hack involving looking for a shortcut action won't work
		# because those aren't exposed:
		# https://github.com/godotengine/godot-proposals/issues/4112
		if child is PopupMenu and child.name == "Layouts":
			return child
		var candidate = find_popup_by_name(name, child)
		if candidate:
			return candidate
	return null

func _enter_tree():
	# Initialization of the plugin goes here.
	layout_picker = preload("layout_picker.tscn").instantiate()
	layout_picker.layout_changer_plugin = self
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, layout_picker)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, layout_picker)
	if layout_picker:
		layout_picker.queue_free()

