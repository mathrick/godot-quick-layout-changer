@tool
extends OptionButton

const DEFAULT_VERSION = "4.3"
const GODOT_VERSION_MAP = {
	"4.2": ["Layouts", false],
	"4.3": ["Editor Layout", true],
}
const REFRESH_ID = -1

const REPO_URL = "https://github.com/mathrick/godot-quick-layout-changer/"

var layout_changer_plugin
var layouts_menu: PopupMenu
var refresh_index: int
var last_active = -1

var _processing = false

func _get_search_target():
	var version_info = Engine.get_version_info()
	var version = "%s.%s" % [version_info.major, version_info.minor]
	return GODOT_VERSION_MAP.get(version, GODOT_VERSION_MAP[DEFAULT_VERSION])

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
	layouts_menu = layout_changer_plugin.find_popup_by_name.callv([null] + _get_search_target()) as PopupMenu
	if not layouts_menu:
		printerr("Could not set up Quick Layout Changer plugin")
		printerr("Please try updating the plugin, or report a bug at %s" % REPO_URL)
		return
	populate()
	layouts_menu.id_pressed.connect(_on_layouts_menu_activated)
	layouts_menu.menu_changed.connect(_on_layouts_menu_changed)
