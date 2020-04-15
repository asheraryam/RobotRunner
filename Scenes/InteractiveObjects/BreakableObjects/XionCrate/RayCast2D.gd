extends RayCast2D

# Abstract class for a basic raycast, Searching for a specific target until it find it
# the signal target_found usually connected by it's parent is emitted whenever
# the first body found by the raycast is the target

signal target_found

var cast_target : Node = null


func _ready():
	set_activate(false)


# Activate the ray cast, until it find a specific target
func search_for_target(target : Node):
	cast_target = target
	set_activate(true)


func set_activate(value: bool):
	set_enabled(value)
	set_physics_process(value)


func _physics_process(_delta):
	if cast_target == null:
		set_activate(false)
		return
	
	
	# Get the relative position of the target
	var dir = global_position.direction_to(cast_target.global_position)
	var dist = global_position.distance_to(cast_target.global_position)
	var relative_target_pos = dir * dist
	
	set_cast_to(relative_target_pos)
	if get_collider() == cast_target:
		emit_signal("target_found", cast_target)
		set_activate(false)
