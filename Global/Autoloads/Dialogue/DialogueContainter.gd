extends AutoloadBase

onready var dialogue_box_scene = preload("res://Scenes/GUI/Dialogue/DialogueBox.tscn")
onready var translations_path_array = ProjectSettings.get_setting("locale/translations")

var current_translation : Translation setget set_current_translation, get_current_translation

var default_locale : String = "en"

#### ACCESSORS ####

func set_current_translation(value: Translation):
	current_translation = value


func get_current_translation():
	return current_translation


func get_dialogue_key(index: int) -> String:
	var scene_name = get_tree().get_current_scene().get_name()
	scene_name = scene_name.to_upper()
	var key : String = "DIAL_" + scene_name + "_" + String(index)
	print_notification(key)
	return key


#### BUILT-IN ####

func _ready():
	#debug = true
	TranslationServer.set_locale(default_locale)
	set_current_translation_by_locale(default_locale)


#### LOGIC ####

func set_current_translation_by_locale(locale: String):
	TranslationServer.set_locale(locale)
	current_translation = get_translation_by_locale(locale)


func get_translation_by_locale(locale: String) -> Translation:
	for path in translations_path_array:
		var trans = load(path)
		if trans.get_locale() == locale:
			return trans
	return null


func destroy_all_dialogue_boxes():
	var dialogue_container = get_tree().get_current_scene().find_node("DialogueContainer")
	for child in dialogue_container.get_children():
		if child is DialogueBox:
			child.queue_free()


func instanciate_dialogue_box(index : int, cut_scene : bool = false):
	destroy_all_dialogue_boxes()
	
	var box_node = dialogue_box_scene.instance()
	box_node.dialogue_key = get_dialogue_key(index)
	box_node.cut_scene = cut_scene
	var dialogue_container = get_tree().get_current_scene().find_node("DialogueContainer")
	dialogue_container.call_deferred("add_child", box_node)
