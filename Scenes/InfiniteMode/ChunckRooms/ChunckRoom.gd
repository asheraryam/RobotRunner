extends Node
class_name ChunckRoom

const AVERAGE_PLTF_LEN : int = 3

var liquid_scenes : Dictionary = {
	"Water" : preload("res://Scenes/InteractiveObjects/Liquids/Water/Water.tscn"),
	"Lava" : preload("res://Scenes/InteractiveObjects/Liquids/Lava/Lava.tscn")
}

export var min_room_size := Vector2(8, 6)
export var max_room_size := Vector2(20, 9)

var room_rect := Rect2() setget set_room_rect, get_room_rect
var bin_map : Array = []

var chunck = null

var entry_exit_couple_array := Array()
var interactive_objects := Array()
var platforms_array := Array()


#### ACCESSORS ####

func is_class(value: String): return value == "ChunckRoom" or .is_class(value)
func get_class() -> String: return "ChunckRoom"

func set_room_rect(value: Rect2): room_rect = value
func get_room_rect() -> Rect2: return room_rect


#### BUILT-IN ####

func _ready():
	var _err = chunck.connect("every_automata_finished", self, "on_every_automata_finished")
	generate()


#### LOGIC ####

func generate():
	var size_x = int(rand_range(min_room_size.x, max_room_size.x + 1))
	var size_y = int(rand_range(min_room_size.y, max_room_size.y + 1))
	var room_size = Vector2(size_x, size_y)
	
	var pos_x = int(rand_range(1, ChunckBin.chunck_tile_size.x - size_x - 1))
	var pos_y = int(rand_range(1, ChunckBin.chunck_tile_size.y - size_y - 1))
	var room_pos = Vector2(pos_x, pos_y)
	
	set_room_rect(Rect2(room_pos, room_size))
	create_bin_map()


# Generate the platform so they are always playable and add a node representation 
# of their data as a child of this node
func generate_platforms():
	for couple in entry_exit_couple_array:
		var entry = couple[0]
		var exit = couple[1]
		
		# If one exit is close enough from the ground, ignore it (Doesn't need platform)
		if exit.y >= room_rect.size.y - 3: continue
		 
		var jump_max_dist : Vector2 = GAME.JUMP_MAX_DIST
		var room_size = get_room_rect().size
		
		var nb_platform = int(round(room_size.x / (jump_max_dist.x + AVERAGE_PLTF_LEN) + 1))
		var entry_point_cell = get_playable_access(entry)
		var average_dist = clamp(int(room_size.x / nb_platform + 1), 3.0, GAME.JUMP_MAX_DIST.x - 1)
		
		var last_platform_end : Vector2 = entry_point_cell
		var platform_avg_y = entry_point_cell.y
		
		var half_chuck_y = int(ChunckBin.chunck_tile_size.y / 2) 
		var first_half : bool = entry.y + room_rect.position.y <= half_chuck_y
		var stair_needed : bool = entry_point_cell.y - exit.y > GAME.JUMP_MAX_DIST.y
		
		# Platform generation, loop through every platfroms
		for i in range(nb_platform):
			var final_platform : bool = i == nb_platform - 1_
			var platform_len = randi() % 2 + 2
			var platform_x_dist = average_dist + int(round(rand_range(-1.0, 1.0)))
			var rdm_y_offset = int(round(rand_range(-1.0, 1.0)))
			
			# Assure the first platform is close enough from the starting point
			# But far enough for it not to block the way
			# it should also always be a the level of the starting point or lower
			if i == 0: 
				platform_x_dist /= 2
				platform_x_dist = clamp(platform_x_dist, 2, INF)
				rdm_y_offset = clamp(rdm_y_offset, 0 , 1.0)
			
			var dist := Vector2(platform_x_dist, - i * int(stair_needed))
			var platform_start := Vector2(last_platform_end.x, platform_avg_y) + dist
			
			# Handle the random height in case the platform arn't a stair case
			if !stair_needed:
				platform_start += Vector2(0, 1) * rdm_y_offset
			
			# Assure the platform position is at least 4 tiles away from the ceiling & 2 away from the floor
			platform_start = Vector2(platform_start.x, clamp(platform_start.y + 1, 4, room_rect.size.y - 3))
			var current_y := platform_start.y
			
			if first_half:
				current_y = clamp(current_y, 4, half_chuck_y)
			else:
				current_y = clamp(current_y, half_chuck_y + 4, room_size.y - 1)
			
			# Assure the last platform is close enough from the exit in the y axis
			# & not to close in the x axis (so their is a )
			if final_platform:
				if is_jump_possible(last_platform_end, exit): continue
				current_y = int(clamp(current_y, exit.y + 1, exit.y + 2))
			
			platform_start = Vector2(platform_start.x, current_y)
			
			# Assure the last platform is needed, and if so, place it correctly
			var dist_to_room_end = exit.x - (platform_start.x + platform_len)
			if dist_to_room_end < 2:
				platform_len += dist_to_room_end
			
			# Add the platform as a node child of this one 
			if platform_len > 1:
				var platform = ChunckPlatform.new(platform_start, Vector2(platform_len, 1))
				platforms_array.append(platform)
			
			last_platform_end = platform_start + Vector2(platform_len, 0)


func is_jump_possible(from: Vector2, to: Vector2):
	return to.x - from.x < GAME.JUMP_MAX_DIST.x && \
	 to.y - from.y < GAME.JUMP_MAX_DIST.y


# Place the platforms into the bin map
func place_platforms():
	for plt in platforms_array:
		for j in range(plt.get_size().y):
			for i in range(plt.get_size().x):
				var current_x = plt.get_start_cell().x + i
				var current_y = plt.get_start_cell().y + j
				bin_map[current_y][current_x] = 1


# Convert the theorical entry point in the concrete one
# ie the point from where the player can jump
func get_playable_access(access: Vector2, exit: bool = false) -> Vector2:
	var rel_access = _cell_rel_to_abs(access)
	var point = rel_access + Vector2.LEFT if !exit else rel_access + Vector2.RIGHT
	var chunck_bin_map = chunck.get_chunck_bin().bin_map
	var chunck_size = ChunckBin.chunck_tile_size
	
	for i in range(chunck_size.y):
		if chunck_bin_map[point.y + i][point.x] == 1:
			return access + Vector2(0, i - 1)
	return access


# Convert a relative cell (relative to the room) to an absolute cell (relative to the whole chunck) 
func _cell_rel_to_abs(cell: Vector2) -> Vector2:
	return cell + room_rect.position


# Convert a absolute cell (relative to the whole chunck) to a relative cell (relative to the room)
func _cell_abs_to_rel(cell: Vector2, clamp_pos: bool = false) -> Vector2:
	var rel_cell = cell - room_rect.position
	if clamp_pos:
		rel_cell = Vector2(clamp(rel_cell.x, 0, room_rect.size.x - 1),
						   clamp(rel_cell.y, 0, room_rect.size.y - 1))
	return rel_cell


# Fill the bin map with 0, and set its size a the same size as the room
func create_bin_map():
	var room_size = get_room_rect().size
	
	for _i in range(room_size.y):
		var line_array = Array()
		for _j in range(room_size.x):
			line_array.append(0)
		bin_map.append(line_array)


# Returns the top most couple of entry and exit
func get_top_entry_exit_couple() -> Array:
	var nb_couples = entry_exit_couple_array.size()
	if nb_couples == 0: return []
	elif nb_couples == 1: return entry_exit_couple_array[0]
	
	if entry_exit_couple_array[0][0].y < entry_exit_couple_array[1][0].y:
		return entry_exit_couple_array[0]
	else: 
		return entry_exit_couple_array[1]


# Generate a liquid in the room if the conditions are met
func generate_liquid(liquid_type: String):
	var lowest_access = find_lowest_room_access()
	var y_max_pool_size = room_rect.size.y - lowest_access.y - 2
	
	var lowest_platform = find_lowest_platfrom()
	
	# Clamp the size of the liquid to be under the lowest platform level
	if lowest_platform != null:
		var lowest_platform_bottom = lowest_platform.get_start_cell().y + lowest_platform.get_size().y
		var pltf_dist_to_floor = room_rect.size.y - lowest_platform_bottom
		y_max_pool_size = min(y_max_pool_size, pltf_dist_to_floor)
	
	if y_max_pool_size <= 1:
		return
	
	var existing_liquid_types = liquid_scenes.keys()
	
	if !(liquid_type in existing_liquid_types):
		print("The liquid type: " + liquid_type + " passed in generate_liquid in class " + name + " doesn't exists")
		return
	
	var liquid_node = liquid_scenes[liquid_type].instance()
	interactive_objects.append(liquid_node)
	
	var pool_size = Vector2(room_rect.size.x, y_max_pool_size) * GAME.TILE_SIZE
	liquid_node.set_pool_size(pool_size)
	
	var pool_sprite_size = Vector2(pool_size.x, pool_size.y + liquid_node.empty_part)
	var pos = (room_rect.position + room_rect.size) * GAME.TILE_SIZE - pool_sprite_size / 2
	liquid_node.set_position(pos)


# Find the lowest access to the room (The closest access to the floor pf the room)
func find_lowest_room_access() -> Vector2:
	var lowest_access := -Vector2.INF
	for couple in entry_exit_couple_array:
		for i in range(couple.size()):
			var is_exit : bool = i == 1
			var access = get_playable_access(couple[i], is_exit) 
			if access.y > lowest_access.y:
				lowest_access = access
	return lowest_access


# Return the lowest platform (on the y axis)
func find_lowest_platfrom() -> ChunckPlatform:
	var lowest_platform: ChunckPlatform
	var lowest_pos := Vector2.ZERO
	for platform in platforms_array:
		var pltf_pos = platform.get_start_cell() + platform.get_size()
		if pltf_pos.y > lowest_pos.y:
			lowest_pos = pltf_pos
			lowest_platform = platform
	return lowest_platform

#### VIRTUALS ####


#### INPUTS ####


#### SIGNAL RESPONSES ####

func on_automata_entered(entry: Vector2, exit: Vector2):
	entry_exit_couple_array.append([_cell_abs_to_rel(entry, true), _cell_abs_to_rel(exit, true)])

func on_every_automata_finished():
	pass
