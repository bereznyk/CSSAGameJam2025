extends Area2D

@onready var game_manager = get_tree().root.get_node("Main/GameManager")
@onready var sprite = %Sprite2D
@onready var despawn_radius = %DespawnRadius
@onready var despawn_timer = %DespawnTimer

var spawned = false
var despawnable = true

const MIN_DESPAWN = 10
const MAX_DESPAWN = 20

func _ready() -> void:
	despawn_timer.wait_time = randi_range(MIN_DESPAWN, MAX_DESPAWN)
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	if not spawned:
		await get_tree().physics_frame
		
		if colliding_with_object():
			delete_enemy()
		else:
			spawned = true
			sprite.visible = true
			set_deferred("monitoring", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and spawned:
		if is_instance_valid(game_manager):
			game_manager.end_game()

func colliding_with_object():
	# don't spawn if on top of something, or near the player
	return (get_overlapping_areas().size() > 0 
		or get_overlapping_bodies().size() > 0
		or despawn_radius.get_overlapping_bodies().size() > 0)

func delete_enemy():
	queue_free()
	game_manager.num_enemies -= 1

func _on_despawn_timer_timeout() -> void:
	# if enemy is not near the player let it despawn
	if despawnable:
		delete_enemy()

func _on_despawn_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		despawnable = false

func _on_despawn_radius_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		despawnable = true
