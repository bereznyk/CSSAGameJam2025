extends CharacterBody2D

var game_manager = get_tree().root.get_node("Main/GameManager")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		pass
