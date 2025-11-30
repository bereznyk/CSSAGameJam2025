extends Node

var game_over = false
var spawning = false
var score = 0

const ZOOM_IN = Vector2(0.05, 0.05)
const ZOOM_SPEED = 0.5 # how fast camera zooms out
const ZOOM_RATE = 2 # how many shapes to pick up before zooming in
var zoom_count = 0 # too keep track for when we should zoom
var curr_zoom = Vector2(1.5, 1.5)

var num_shapes = 0 # Number of shapes on the map
var num_enemies = 0 # Number of enemies on the map

const MAX_SHAPES = 30
const MAX_ENEMIES = 80

@onready var game_score = %GameScore
@onready var death_screen = %Death
@onready var end_score = %EndScore
@onready var camera = %Camera
@onready var death_sound = %DeathSound
@onready var pickup_sound = %PickupSound

const DEATH_SOUND_START = 1.5
const PICKUP_SOUND_START = 1.52

const MIN_X = -1150
const MAX_X = 1150
const MIN_Y = -1150
const MAX_Y = 1150

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

const enemy_spawn_rates = [
	0.5,
	0.8,
	1.0,
]

const ENEMY_SIZE_RANGE = 0.1

func _ready():
	spawning = true
	camera.zoom = curr_zoom

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
	
	# Zoom camera in if needed
	camera.zoom = camera.zoom.move_toward(curr_zoom, ZOOM_SPEED * delta)

func end_game():
	death_sound.play(DEATH_SOUND_START)
	
	game_over = true
	spawning = false
	get_tree().paused = true
	
	end_score.text = str(score)
	death_screen.visible = true
	end_score.visible = true
	
	game_score.visible = false

func update_score(count):
	pickup_sound.play(PICKUP_SOUND_START)
	
	score += count
	num_shapes -= 1
	game_score.text = "Score: " + str(score)
	
	zoom_count = (zoom_count + 1) % ZOOM_RATE
	if zoom_count == 0:
		curr_zoom -= ZOOM_IN # zoom in camera on collecting shape

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
	var enemy_roll = randf()
	var enemy_to_spawn = 0
	
	while enemy_roll > enemy_spawn_rates[enemy_to_spawn] and enemy_to_spawn < Enemy.NUM_ENEMIES - 1:
		enemy_to_spawn += 1
	
	var new_enemy = enemies[enemy_to_spawn].instantiate()
	new_enemy.position = get_spawn_cords()
	
	var new_scale = randf_range(1 - ENEMY_SIZE_RANGE, 1 + 2*ENEMY_SIZE_RANGE)
	new_enemy.scale *= new_scale
	
	# just to stop a crash on reload
	if get_tree() != null:
		get_tree().current_scene.add_child(new_enemy)
		
	num_enemies += 1
