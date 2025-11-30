extends "res://scripts/enemy.gd"

const MIN_X = -900
const MAX_X = 900
const MIN_Y = -900
const MAX_Y = 900

# how far patrol points should be
const PATROL_RANGE = 100
const PATROL_SPEED_RANGE = 25
const MAX_PATROL_POINTS = 5
var patrol_points = []
var num_points = 0
var curr_point = 1
var move_speed = 50
var in_patrol = false

func _ready() -> void:
	move_speed += randi_range(-PATROL_SPEED_RANGE, PATROL_SPEED_RANGE)
	
	# add current position as a point
	patrol_points.append(position)
	
	# add the rest of the points
	num_points = randi_range(2, MAX_PATROL_POINTS)
	while patrol_points.size() < num_points:
		patrol_points.append(create_new_point())
	
	super._ready()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if spawned and not in_patrol:
		var distance = position.distance_to(patrol_points[curr_point])
		var duration = distance / move_speed
		
		var tween = create_tween()
		tween.tween_property(self, "position", patrol_points[curr_point], duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(Callable(self, "_on_tween_complete"))
		tween.play()
		
		curr_point = (curr_point + 1) % num_points
		in_patrol = true

func create_new_point():
	var new_x = clamp(randi_range(position.x - PATROL_RANGE, position.x + PATROL_RANGE), MIN_X, MAX_X)
	var new_y = clamp(randi_range(position.y - PATROL_RANGE, position.y + PATROL_RANGE), MIN_Y, MAX_Y)
	return Vector2(new_x, new_y)

func _on_tween_complete():
	in_patrol = false
