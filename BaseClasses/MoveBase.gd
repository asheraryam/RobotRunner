extends PlayerStateBase

class_name MoveBase

### MOVE STATE ###

signal layer_change

var state_node : Node
var character_node : KinematicBody2D
var layer_change_node : Node
var attributes_node : Node

func setup():
	var _err = connect("layer_change", layer_change_node, "on_layer_change")

func update(_host, _delta):
	if !character_node.is_on_floor():
		return "Fall"
	elif attributes_node.velocity.x == 0:
		return "Idle"

func on_JumpPressed():
	state_node.set_state("Jump")

func on_LayerUpPressed():
	emit_signal("layer_change", true)

func on_LayerDownPressed():
	emit_signal("layer_change", false)

func on_ActionPressed():
	state_node.set_state("Action")

func enter_state(_host):
	animation_node.play(self.name)
	if !character_node.is_on_floor():
		state_node.set_state("Jump")