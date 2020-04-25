extends StatesMachine

# Define the list of possible states, and give the path to the corresponding node for each state
# The states are distinguished by the name of their corresponding node
# The default state is always the first in the tree

var inputs_node : Node 
var layer_change_node : Node
var hit_box_node : Node
var animation_node : AnimatedSprite
var SFX_node : Node

var previous_anim_node
var curent_anim_node

func _ready():
	set_physics_process(false)

func setup():
	# Give the needed references to the children
	for state in states_map:
		if "state_node" in state:
			state.state_node = self
		
		if "inputs_node" in state:
			state.inputs_node = inputs_node
		
		if "layer_change_node" in state:
			state.layer_change_node = layer_change_node
		
		if "hit_box_node" in state:
			state.hit_box_node = hit_box_node
		
		if "animation_node" in state:
			state.animation_node = animation_node
		
		if "SFX_node" in state:
			state.SFX_node = SFX_node
		
		if state.has_method("setup"):
			state.setup()
	
	set_physics_process(true)
	set_state(states_map[0])
