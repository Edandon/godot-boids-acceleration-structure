extends Node2D
class_name Boid

@export var max_speed: float = 100.0
@export var min_speed: float = 80.0
@export var target_force: float = 2.0
@export var cohesion: float = 2.0
@export var alignment: float = 3.0
@export var separation: float = 5.0
@export var view_distance: float = 50.0
@export var avoid_distance: float = 15.0
@export var max_flock_size: int = 15
@export var screen_avoid_force: float = 10.0

@onready var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))


var _targets = []
var velocity: Vector2
var stay_on_screen: = true

# a 2D array of "cells"
var flock = []
var flock_size: int = 0


func _ready():
	randomize()
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * max_speed


func process(delta):
	position += velocity * delta
	
	var screen_avoid_vector = Vector2.ZERO
	if stay_on_screen:
		screen_avoid_vector = avoid_screen_edge() * screen_avoid_force
	else:
		wrap_screen()

	# get cohesion, alginment, and separation vectors
	var vectors = get_flock_status()
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion
	var align_vector = vectors[1] * alignment
	var separation_vector = vectors[2] * separation
	flock_size = vectors[3]

	var acceleration = align_vector + cohesion_vector + separation_vector + screen_avoid_vector
	if _targets:
		var target_vector = Vector2.ZERO
		for target in _targets:
			target_vector += global_position.direction_to(target)
		target_vector /= _targets.size()
		acceleration += target_vector * target_force
	
	velocity = (velocity + acceleration).limit_length(max_speed)
	if velocity.length() <= min_speed:
		velocity = (velocity * min_speed).limit_length(max_speed)


func get_flock_status():
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	var other_count: = 0

	for cell in flock:
		for other in cell:
			if other_count == max_flock_size:
				break

			if other == self:
				continue

			var other_pos: Vector2 = other.global_position
			var other_velocity: Vector2 = other.velocity
	
			if global_position.distance_to(other_pos) < view_distance:
				other_count += 1
				align_vector += other_velocity
				flock_center += other_pos
		
				var d = global_position.distance_to(other_pos)
				if d < avoid_distance:
					avoid_vector -= other_pos - global_position

	if other_count:
		align_vector /= other_count
		flock_center /= other_count
		center_vector = global_position.direction_to(flock_center)

	return [center_vector.normalized(),
			align_vector.normalized(), 
			avoid_vector.normalized(), 
			other_count]


func get_random_target():
	randomize()
	return Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))


func avoid_screen_edge():
	var edge_avoid_vector: = Vector2.ZERO
	if position.x - avoid_distance < 0:
		edge_avoid_vector.x = 1
	elif position.x + avoid_distance > screen_size.x:
		edge_avoid_vector.x = -1
	if position.y - avoid_distance < 0:
		edge_avoid_vector.y = 1
	elif position.y + avoid_distance > screen_size.y:
		edge_avoid_vector.y = -1
	
	return edge_avoid_vector.normalized()


func wrap_screen():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)


func set_values(params: Dictionary):
	for param in params.keys():
		set(param, params[param])


func add_target(target_position: Vector2):
	_targets.append(target_position)


func clear_targets():
	_targets.clear()


func set_max_speed(value: float):
	max_speed = value


func set_min_speed(value:float):
	min_speed = value


func set_target_force(value:float):
	target_force = value


func set_cohesion(value:float):
	cohesion = value


func set_alignment(value:float):
	alignment = value


func set_separation(value:float):
	separation = value


func set_view_distance(value:float):
	view_distance = value


func set_avoid_distance(value:float):
	avoid_distance = value


func set_max_flock_size(value:float):
	max_flock_size = value
