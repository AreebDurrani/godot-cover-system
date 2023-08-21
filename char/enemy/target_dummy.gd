class_name TargetDummy extends RigidBody3D
@onready var collider = $collider
@onready var capsule = $capsule
@onready var nav = $nav 
@export var crouching = false
@export var max_speed = 5
@export var acceleration = 5000
var cover_point : CoverPoint

func _physics_process(_delta):
	handle_crouch()


func _integrate_forces(state):
	var new_position = nav.get_next_path_position()
	var direction = (new_position - global_position).normalized() * acceleration
	if not max_speed_reached(state):
		state.apply_central_force(direction)
	

func _ready():
	crouching = false
	cover_point = find_cover("player_team")
	cover_point.occupied = true
	nav.set_target_position(cover_point.global_position)

func handle_crouch():
	if crouching: 
		if collider.get_scale().y > 0.5 or capsule.get_scale().y > 0.5:
			collider.scale.y = lerp(collider.scale.y, 0.5, 0.1)
			capsule.scale.y = lerp(capsule.scale.y, 0.5, 0.1)
	if not crouching:
		if collider.get_scale().y < 1 or capsule.get_scale().y < 1:
			collider.scale.y = lerp(collider.scale.y, 1, 0.1)
			capsule.scale.y = lerp(capsule.scale.y, 1, 0.1)

func find_cover(enemy_team : String) -> CoverPoint:
	var hidden_points : Array[CoverPoint]
	
	for n in get_tree().get_nodes_in_group("coverpoint"):
		if n is CoverPoint:
			if n.occupied == false:
				for e in get_tree().get_nodes_in_group(enemy_team):
					var space_state = get_world_3d().direct_space_state
					var query = PhysicsRayQueryParameters3D.create(n.global_position, e.global_position)
					query.exclude = [self]
					var result = space_state.intersect_ray(query)
					if result.collider != e:
						n.num_hidden_from +=1
				n.distance = global_position.distance_to(n.global_position)
				hidden_points.append(n)
	hidden_points.sort_custom(cover_quality)
	return hidden_points[0]

func cover_quality(a : CoverPoint, b : CoverPoint) -> bool:
	return (a.num_hidden_from/a.distance) > (b.num_hidden_from/b.distance)

func max_speed_reached(state : PhysicsDirectBodyState3D) -> bool:
	return state.linear_velocity.length() >= max_speed or state.linear_velocity.length() <= -max_speed


func _on_nav_navigation_finished():
	crouching = true;
