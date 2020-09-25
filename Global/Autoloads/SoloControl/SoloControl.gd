extends Node

var solo_mode : bool = false setget set_solo_mode, get_solo_mode

#### ACCESSORS ####

func set_solo_mode(value: bool): 
	solo_mode = value
	if !solo_mode:
		for player in get_tree().get_nodes_in_group("Players"):
			player.set_active(true)

func get_solo_mode() -> bool: return solo_mode

#### BUILT-IN ####



#### LOGIC ####



#### VIRTUALS ####



#### INPUTS ####

# Manage the robot switching
func _input(_event):
	if !solo_mode:
		return
	
	var players_array = get_tree().get_nodes_in_group("Players")
	var target : int = -1
	
	if Input.is_action_just_pressed("both_chara"):
		target = 0
	elif Input.is_action_just_pressed("chara1"):
		target = 1
	elif Input.is_action_just_pressed("chara2"):
		target = 2
	else:
		return
	
	for player in players_array:
		# In case the player wants every robots active
		if target == 0:
			player.set_active(true)
			continue
		
		# In case the player wants one robot active only, 
		# set it to active and every other one to inactive
		var id = player.get_player_id()
		player.set_active(id == target)


#### SIGNAL RESPONSES ####
