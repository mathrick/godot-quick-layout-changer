@tool
extends OptionButton

const MENU_NAME = "Layouts"
const REFRESH_ID = -1

var layout_changer_plugin
var layouts_menu: PopupMenu
var refresh_index: int
var last_active = -1

var _processing = false

func get_first_layout_index() -> int:
	var first_layout_index = 0
	var found = false
	while first_layout_index < layouts_menu.item_count:
		if layouts_menu.is_item_separator(first_layout_index):
			found = true
			break
		first_layout_index += 1
	if not found:
		return -1
	# +1 to skip the separator
	return first_layout_index + 1

func populate():
	#var active_layout = get_item_text(last_active) if last_active != -1 else null
	var active_layout = null
	var active_index = -1

	clear()

	var first_layout_index = get_first_layout_index()
	if first_layout_index < 0:
		return
	for i in range(first_layout_index, layouts_menu.item_count):
		var layout = layouts_menu.get_item_text(i)
		add_item(layout)
		if active_layout and layout == active_layout:
			active_index = i - first_layout_index
	add_separator()
	get_popup().add_item("Refresh")
	set_item_id(item_count - 1, REFRESH_ID)
	selected = active_index
	if last_active == -1:
		text = "Layout"

func _on_layouts_menu_activated(id: int):
	if _processing:
		return

	var index = layouts_menu.get_item_index(id)
	var first_layout_index = get_first_layout_index()
	if index >= first_layout_index:
		populate()
		selected = index - first_layout_index
		last_active = selected

func _on_layouts_menu_changed():
	populate()

func _on_item_selected(index):
	if get_item_id(index) == REFRESH_ID:
		populate()
		return

	last_active = index
	var active_layout = get_item_text(index)
	for i in range(get_first_layout_index(), layouts_menu.item_count):
		if layouts_menu.get_item_text(i) == active_layout:
			_processing = true
			layouts_menu.id_pressed.emit(layouts_menu.get_item_id(i))
			_processing = false
			return

# Called when the node enters the scene tree for the first time.
func _ready():
	layouts_menu = layout_changer_plugin.find_popup_by_name(MENU_NAME) as PopupMenu
	populate()
	layouts_menu.id_pressed.connect(_on_layouts_menu_activated)
	layouts_menu.menu_changed.connect(_on_layouts_menu_changed)
