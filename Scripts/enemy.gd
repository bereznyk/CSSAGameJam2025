extends Area2D

@onready var game_manager = get_tree().root.get_node("Main/GameManager")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		game_manager.end_game()
