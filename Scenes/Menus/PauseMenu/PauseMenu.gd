extends MenuBase
class_name PauseMenu

onready var resume_label_node = $HBoxContainer/V_OptContainer/Resume



#### BUILT-IN ####

func _ready() -> void:
	get_tree().set_pause(true)

#### LOGIC ####

func resume_game():
	get_tree().set_pause(false)
	queue_free()


#### VITRUAL ####

func cancel() -> void:
	resume_game()


#### INPUTS ####


#### SIGNAL RESPONSES ####

func _on_menu_option_chose(option: MenuOptionsBase):
	var _err = null
	
	match(option.name):
		"Resume":
			resume_game()
		
		"Retry": 
			get_tree().set_pause(false)
			_err = GAME.goto_last_level()
		
		"Options":
			_err = navigate_sub_menu(MENUS.option_menu_scene.instance())
		
		"SaveGame":
			_err = navigate_sub_menu(MENUS.slotsaver_menu_scene.instance())
		
		"Quit": 
			get_tree().set_pause(false)
			_err = get_tree().change_scene_to(MENUS.title_screen_scene)
