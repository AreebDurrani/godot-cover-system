class_name Ally extends RigidBody3D

@onready var shape_cast = $shape_cast
@export var look_speed = 0.01
@export var jump_force = 500
@export var acceleration = 5000
@export var max_speed = 5
@export var target : Node3D
@onready var nav = $nav

func _ready():
	nav.set_target_position(target.position)

#move to target using navigation, unless target is null, 
#in which case do nothing
func _integrate_forces(state):
	if nav.target_position:
		var new_pos = nav.get_next_path_position()
		var direction = (new_pos - position).normalized()
		if direction and !max_speed_reached(state):
			state.apply_central_force(Vector3(direction.x * acceleration, 0, direction.z * acceleration))

func is_on_floor():
	return shape_cast.is_colliding()

func max_speed_reached(state):
	return state.linear_velocity.length() >= max_speed or linear_velocity.length() <= -max_speed


func _on_nav_navigation_finished():
	nav.target_position = null
