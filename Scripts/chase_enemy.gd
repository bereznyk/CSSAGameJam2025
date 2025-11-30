extends "res://scripts/enemy.gd"

@onready var chase_collider = %CollisionShape2D

const CHASE_RANGE = 100
const CHASE_SPEED_RANGE = 25
var chase_speed = 50
var in_chase = false
var player = null

func _ready() -> void:
	chase_collider.shape = chase_collider.shape.duplicate()
	chase_collider.shape.radius += randi_range(-CHASE_RANGE, CHASE_RANGE)
	print(chase_collider.shape.radius)
	chase_speed += randi_range(-CHASE_SPEED_RANGE, CHASE_SPEED_RANGE)
	
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if spawned and in_chase and player != null:
		var chase_dir = (player.global_position - global_position).normalized()
		position += chase_dir * chase_speed * delta

func _on_chase_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_chase = true
		player = body

func _on_chase_radius_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_chase = false
