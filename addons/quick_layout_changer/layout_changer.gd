@tool
class_name LayoutChanger extends EditorPlugin

const LayoutPicker = preload("layout_picker.gd")
var layout_picker: LayoutPicker

func find_popup_by_name(node, name, descend_into_items=false) -> PopupMenu:
	if node == null:
		node = get_tree().root
	# FIXME: This is horribly hacky and there are probably a 1001 ways in which it can
	# break, but I don't think we can do any better with the current editor API. In 4.2,
	# "Layouts" is never localised, unlike in 4.3. Either way, there's nothing we can do
	# to manipulate layouts directly, and a slightly better hack involving looking for a
	# shortcut action won't work because those aren't exposed:
	# https://github.com/godotengine/godot-proposals/issues/4112
	var _children = []
	if node is PopupMenu:
		if node.name == name:
			return node
		if descend_into_items:
			for item in node.item_count:
				var submenu = node.get_item_submenu_node(item)
				if node.get_item_text(item) == name:
					return submenu
				if submenu:
					_children.append(submenu)
	for child in _children if _children else node.get_children():
		var candidate = find_popup_by_name(child, name, descend_into_items)
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
