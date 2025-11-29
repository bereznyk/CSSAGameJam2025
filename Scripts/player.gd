extends CharacterBody2D

@export var speed = 400
@export var rotation_speed = 2

var rotation_direction = 0

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	rotation_direction = Input.get_axis("rotate_left", "rotate_right")

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
