extends Node2D

export var max_speed: = 200.0
export var mouse_follow_force: = 0.05
export var cohesion_force: = 0.05
export var algin_force: = 0.05
export var separation_force: = 0.05
export(float) var view_distance: = 50.0
export(float) var avoid_distance: = 20.0


var _width = ProjectSettings.get_setting("display/window/size/width")
var _height = ProjectSettings.get_setting("display/window/size/height")

var _flock: = [] setget set_flock, get_flock
 
var _mouse_target: Vector2
var _velocity: Vector2


func _ready():
	randomize()
	_velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * max_speed
	_mouse_target = get_random_target()


func _input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT:
			_mouse_target = event.position
		elif event.get_button_index() == BUTTON_RIGHT:
			_mouse_target = get_random_target()


func _physics_process(delta):
	
	var mouse_vector = Vector2.ZERO
	if _mouse_target != Vector2.INF:
		mouse_vector = global_position.direction_to(_mouse_target) * max_speed * mouse_follow_force
	
	# get cohesion, alginment, and separation vectors
	var vectors = get_flock_status(_flock)
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force

	var acceleration = cohesion_vector + align_vector + separation_vector + mouse_vector
	
	_velocity = (_velocity + acceleration).clamped(max_speed)
	
	translate(_velocity * delta)


func get_flock_status(flock: Array):
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	var flock_size: = 0
	
	for f in flock:
		var neighbor_pos: Vector2 = f.global_position

		if global_position.distance_to(neighbor_pos) < view_distance:
			flock_size += 1
			align_vector += f._velocity
			flock_center += neighbor_pos
	
			var d = global_position.distance_to(neighbor_pos)
			if d > 0 and d < avoid_distance:
				avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * max_speed)
	
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size

		var center_dir = global_position.direction_to(flock_center)
		var center_speed = max_speed * (global_position.distance_to(flock_center) / view_distance)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector]


func get_random_target():
	randomize()
	return Vector2(rand_range(0, _width), rand_range(0, _height))


func set_flock(flock: Array) -> void:
	_flock = flock


func get_flock() -> Array:
	return _flock