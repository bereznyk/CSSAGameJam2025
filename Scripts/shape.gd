extends CollisionShape2D

@export var value = 1 # amount of score added

@onready var stick_range: Area2D = %StickRange
@onready var sprite = %Sprite2D
@onready var game_manager = get_tree().root.get_node("Main/GameManager")

var spawned = false

func _physics_process(delta: float) -> void:
	if not spawned:
		await get_tree().physics_frame
		
		if colliding_with_object():
			print("huh1")
			get_parent().queue_free()
			game_manager.num_shapes -= 1
		else:
			spawned = true
			sprite.visible = true
			set_deferred("disabled", false)

# If we collide with player, attach the shape to them
func _on_stick_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and spawned:
		
		if is_instance_valid(game_manager):
			game_manager.update_score(value)
		
		var shape_wall = get_parent()
		stick_to_player(body)
		shape_wall.call_deferred("queue_free")
	
func stick_to_player(player):
	get_parent().call_deferred("remove_child", self)
	player.call_deferred("add_child", self)
	
	position = player.to_local(global_position)
	rotation -= player.rotation
	stick_range.set_deferred("monitoring", false)

func colliding_with_object():
	# greater than 1 cause of the StaticBody2D parent
	return (stick_range.get_overlapping_areas().size() > 0 
		or stick_range.get_overlapping_bodies().size() > 1)
