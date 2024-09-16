@tool
extends OptionButton

const DEFAULT_VERSION = "4.3"
const GODOT_VERSION_MAP = {
	"4.2": {"string": "Layouts", "descend": false},
	"4.3": {"string": "Editor Layout", "descend": true},
}
const TRANSLATIONS = {
	"4.3": {
		'ar': {'string': 'تنسيق المحرّر'},
		'ca': {'string': "Disseny de l'Editor", 'short': 'Disseny'},
		'cs': {'string': 'Rozložení editoru', 'short': 'Rozložení'},
		'de': {'string': 'Editorlayout'},
		'el': {'string': 'Διάταξη επεξεργαστή'},
		'eo': {'string': 'Aranĝo de la redaktilo', 'short': 'Aranĝo'},
		'es': {'string': 'Layout del Editor'},
		'es_AR': {'string': 'Layout del Editor'},
		'et': {'string': 'Redaktori paigutus'},
		'fa': {'string': 'طرح\u200cبندی ویرایشگر'},
		'fi': {'string': 'Editorin ulkoasu'},
		'fr': {'string': "Disposition de l'éditeur", 'short': 'Disposition'},
		'ga': {'string': 'Leagan Amach an Eagarthóra'},
		'gl': {'string': 'Disposición das Ventás do Editor'},
		'he': {'string': 'פריסת עורך'},
		'hu': {'string': 'Szerkesztő Elrendezés'},
		'id': {'string': 'Tata Letak Editor'},
		'it': {'string': "Disposizione dell'editor", 'short': 'Disposizione'},
		'ja': {'string': 'エディターレイアウト', 'short': 'レイアウト'},
		'ko': {'string': '에디터 레이아웃'},
		'lv': {'string': 'Redaktora izkārtojums'},
		'ms': {'string': 'Editor Susun Atur'},
		'nb': {'string': 'Redigeringsverktøy Layout'},
		'nl': {'string': 'Bewerkers­indeling', 'short': 'Indeling'},
		'pl': {'string': 'Układ edytora', 'short': 'Układ'},
		'pt': {'string': 'Apresentação do Editor', 'short': 'Apresentação'},
		'pt_BR': {'string': 'Layout do Editor'},
		'ro': {'string': 'Schema Editor'},
		'ru': {'string': 'Макет редактора', 'short': 'Макет'},
		'sk': {'string': 'Layout Editora'},
		'th': {'string': 'เค้าโครงตัวแก้ไข'},
		'tr': {'string': 'Düzenleyici Yerleşim Düzeni'},
		'uk': {'string': 'Редактор компонування', 'short': 'компонування'},
		'vi': {'string': 'Cài đặt Bố cục'},
		'zh_CN': {'string': '编辑器布局'},
		'zh_TW': {'string': '編輯器配置'},
	}
}
const REFRESH_ID = -1

const REPO_URL = "https://github.com/mathrick/godot-quick-layout-changer/"

var layout_changer_plugin
var layouts_menu: PopupMenu
var refresh_index: int
var last_active = -1

var _processing = false

func _get_search_target() -> Dictionary:
	var version_info = Engine.get_version_info()
	var versions = [
		"%s.%s.%s" % [version_info.major, version_info.minor, version_info.patch],
		"%s.%s" % [version_info.major, version_info.minor],
		DEFAULT_VERSION,
	]
	var result
	var actual_version
	for version in versions:
		if version in GODOT_VERSION_MAP:
			result = GODOT_VERSION_MAP[version].duplicate()
			actual_version = version
			break
	var locale = TranslationServer.get_tool_locale()
	var translation = TRANSLATIONS.get(actual_version, {}).get(locale, {})
	result.string = translation.get("string", result.string)
	# Fall back to English for the short string, since some of the translations are
	# massively unwieldy and long
	result.short = translation.get("short", "Layout")
	return result

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
		text = _get_search_target().short

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
		last_active = -1
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
	var target = _get_search_target()
	layouts_menu = layout_changer_plugin.find_popup_by_name(null, target.string, target.descend) as PopupMenu
	if not layouts_menu:
		printerr("Could not set up Quick Layout Changer plugin")
		printerr("Please try updating the plugin, or report a bug at %s" % REPO_URL)
		return
	populate()
	layouts_menu.id_pressed.connect(_on_layouts_menu_activated)
	layouts_menu.menu_changed.connect(_on_layouts_menu_changed)
