extends Node

var game_over = false
var spawning = false
var score = 0

var num_shapes = 0 # Number of shapes on the map
var num_enemies = 0 # Number of enemies on the map

const MAX_SHAPES = 100
const MAX_ENEMIES = 100

@onready var game_score = %GameScore
@onready var death_screen = %Death
@onready var end_score = %EndScore

const MIN_X = -1100
const MAX_X = 1100
const MIN_Y = -1100
const MAX_Y = 1100

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
const TRIANGLE_SKEW_RANGE = PI/4

enum Enemy {
	BASIC,
	PATROL,
	CHASE,
	NUM_ENEMIES
}

const enemies = [
	preload("res://Objects/Enemies/enemy.tscn"),
	preload("res://Objects/Enemies/patrol_enemy.tscn"),
	preload("res://Objects/Enemies/chase_enemy.tscn"),
]

const ENEMY_SIZE_RANGE = 0.1

func _ready():
	spawning = true

func _process(delta):
	if Input.is_action_just_pressed("restart") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
	
	if spawning:
		# try spawning a shape
		if num_shapes < MAX_SHAPES:
			spawn_shape()
		
		# try spawning an enemy
		if num_enemies < MAX_ENEMIES:
			spawn_enemy()

func end_game():
	game_over = true
	spawning = false
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
	
	var new_scale = randf_range(1 - SHAPE_SIZE_RANGE, 1 + 2*SHAPE_SIZE_RANGE)
	var new_rotation = randf_range(-PI, PI)
	var new_skew = 0
	if shape_to_spawn == Shapes.TRIANGLE:
		new_skew = randf_range(-TRIANGLE_SKEW_RANGE, TRIANGLE_SKEW_RANGE)
		
	new_shape.get_node("ShapeCollider").setup_shape(new_scale, new_rotation, new_skew)
	
	# just to stop a crash on reload
	if get_tree() != null:
		get_tree().current_scene.add_child(new_shape)
		
	num_shapes += 1
	
func spawn_enemy():
	var enemy_to_spawn = randi_range(0, Enemy.NUM_ENEMIES - 1)
	var new_enemy = enemies[enemy_to_spawn].instantiate()
	new_enemy.position = get_spawn_cords()
	
	var new_scale = randf_range(1 - ENEMY_SIZE_RANGE, 1 + 2*ENEMY_SIZE_RANGE)
	new_enemy.scale *= new_scale
	
	# just to stop a crash on reload
	if get_tree() != null:
		get_tree().current_scene.add_child(new_enemy)
		
	num_enemies += 1
