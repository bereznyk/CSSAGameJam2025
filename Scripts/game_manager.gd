extends Node

var game_over = false
var score = 0

var num_shapes = 0 # Number of shapes on the map
var num_enemies = 0 # Number of enemies on the map

const MAX_SHAPES = 100
const MAX_ENEMIES = 100

@onready var game_score = %GameScore
@onready var death_screen = %Death
@onready var end_score = %EndScore

const MIN_X = -900
const MAX_X = 900
const MIN_Y = -900
const MAX_Y = 900

enum Shapes {
	CIRCLE,
	SQUARE,
	STICK,
	TRIANGLE,
	NUM_SHAPES
}

const shapes_array = [
	preload("res://Objects/Shapes/circle.tscn"),
	preload("res://Objects/Shapes/square.tscn"),
	preload("res://Objects/Shapes/stick.tscn"),
	preload("res://Objects/Shapes/triangle.tscn"),
]

const SHAPE_SIZE_RANGE = 0.25
const TRIANGLE_SKEW_RANGE = 0.5

enum Enemy {
	BASIC,
	PATROL,
	CHASE,
	NUM_ENEMIES
}

const enemies = [
	preload("res://Objects/Enemies/enemy.tscn"),
	preload("res://Objects/Enemies/enemy.tscn"),
	preload("res://Objects/Enemies/enemy.tscn"),
]

const ENEMY_SIZE_RANGE = 0.1

func _process(delta):
	if Input.is_action_just_pressed("restart") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	if num_shapes < MAX_SHAPES:
		spawn_shape()
		
	if num_enemies < MAX_ENEMIES:
		spawn_enemy()
		
func restart_game():
	
	for child in get_children():
		child.queue_free()

func end_game():
	game_over = true
	get_tree().paused = true
	
	end_score.text = str(score)
	death_screen.visible = true
	end_score.visible = true
	
	game_score.visible = false

func update_score(count):
	score += count
	num_shapes -= 1
	game_score.text = "Score: " + str(score)

func get_spawn_cords():
	return Vector2(randi_range(MIN_X, MAX_X), randi_range(MIN_Y, MAX_Y))

func spawn_shape():
	var shape_to_spawn = randi_range(0, Shapes.NUM_SHAPES - 1)
	var new_shape = shapes_array[shape_to_spawn].instantiate()
	new_shape.position = get_spawn_cords()
	
	# just to stop a crash on reload
	if get_tree() != null:
		get_tree().current_scene.add_child(new_shape)
		
	num_shapes += 1
	
func spawn_enemy():
	var enemy_to_spawn = randi_range(0, Enemy.NUM_ENEMIES - 1)
	var new_enemy = enemies[enemy_to_spawn].instantiate()
	new_enemy.position = get_spawn_cords()
	
	# just to stop a crash on reload
	if get_tree() != null:
		get_tree().current_scene.add_child(new_enemy)
		
	num_enemies += 1
