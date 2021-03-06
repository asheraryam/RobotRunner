extends Event
class_name Checkpoint

export var active : bool = false

onready var animated_sprite_node = $AnimatedSprite

signal checkpoint_reached

func is_class(value: String):
	return value == "Checkpoint" or .is_class(value)

func get_class() -> String:
	return "Checkpoint"

func _ready():
	var _err
	_err = animated_sprite_node.connect("animation_finished", self, "on_animation_finished")
	_err = connect("checkpoint_reached",GAME,"on_checkpoint_reached")
	
	if active:
		activate_checkpoint()

func event():
	set_active(true)
	emit_signal("checkpoint_reached", get_tree().get_current_scene(), get_index())


func trigger_animation():
	animated_sprite_node.play("Trigger")
	$AnimationPlayer.play("LightUp")


func activate_checkpoint():
	trigger_animation()
	for area in triggers_area_array:
		area.get_node("CollisionShape2D").call_deferred("set_disabled", true)


func set_active(value : bool):
	active = value
	if active:
		activate_checkpoint()


func on_animation_finished():
	if animated_sprite_node.get_animation() == "Trigger":
		animated_sprite_node.play("Active")
