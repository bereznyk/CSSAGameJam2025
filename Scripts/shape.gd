extends CollisionShape2D

@onready var stick_range: Area2D = %StickRange

# If we collide with player, attach the shape to them
func _on_stick_range_body_entered(body: Node2D) -> void:
	print("wgha")
	if body.is_in_group("Player"):
		var shape_wall = get_parent()
		stick_to_player(body)
		shape_wall.call_deferred("queue_free")

		
func stick_to_player(player):
	get_parent().call_deferred("remove_child", self)
	player.call_deferred("add_child", self)
	
	position = player.to_local(global_position)
	rotation -= player.rotation
	stick_range.set_deferred("monitoring", false)
