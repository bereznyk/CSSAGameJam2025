extends CollisionShape2D

@export var value = 1 # amount of score added

@onready var stick_range: Area2D = %StickRange
@onready var sprite = %Sprite2D
@onready var despawn_timer = %DespawnTimer
@onready var game_manager = get_tree().root.get_node("Main/GameManager")

var spawned = false

const MIN_DESPAWN = 20
const MAX_DESPAWN = 40

func _ready() -> void:
	despawn_timer.wait_time = randi_range(MIN_DESPAWN, MAX_DESPAWN)
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	if not spawned:
		await get_tree().physics_frame
		
		if colliding_with_object():
			delete_static_shape()
		else:
			spawned = true
			sprite.visible = true
			set_deferred("disabled", false)

# deletes shape by deleting static parent object
func delete_static_shape():
	get_parent().queue_free()
	game_manager.num_shapes -= 1
	
func setup_shape(scale, rotation, skew):
	self.scale *= scale
	self.rotation = rotation
	self.skew = skew

# If we collide with player, attach the shape to them
func _on_stick_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and spawned:
		
		if is_instance_valid(game_manager):
			game_manager.update_score(value)
		
		var shape_wall = get_parent()
		stick_to_player(body)
		shape_wall.call_deferred("queue_free")
	
func stick_to_player(player):
	despawn_timer.stop()

	get_parent().call_deferred("remove_child", self)
	player.call_deferred("add_child", self)
	
	set_deferred("position", player.to_local(global_position))
	set_deferred("rotation", rotation - player.rotation)
	
	stick_range.set_deferred("monitoring", false)
	

func colliding_with_object():
	# greater than 1 cause of the StaticBody2D parent
	return (stick_range.get_overlapping_areas().size() > 0 
		or stick_range.get_overlapping_bodies().size() > 1)

func _on_despawn_timer_timeout() -> void:
	delete_static_shape()
