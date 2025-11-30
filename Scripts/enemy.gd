extends Area2D

@onready var game_manager = get_tree().root.get_node("Main/GameManager")
@onready var sprite = %Sprite2D

var spawned = false

func _physics_process(delta: float) -> void:
	if not spawned:
		await get_tree().physics_frame
		
		if colliding_with_object():
			print("huh2a")
			queue_free()
			game_manager.num_enemies -= 1
		else:
			spawned = true
			sprite.visible = true
			set_deferred("monitoring", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and spawned:
		if is_instance_valid(game_manager):
			game_manager.end_game()

func colliding_with_object():
	return (get_overlapping_areas().size() > 0 
		or get_overlapping_bodies().size() > 0)
