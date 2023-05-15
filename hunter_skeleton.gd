class_name hunter_skeleton extends skeleton
var damage = 2

func _ready():
	max_health = 150
	health_bar.max_value = max_health
	health_bar.value = max_health
	switch_to(State.WALK_LEFT)

func _on_hurtbox_body_entered(body):
	if body.name == "Character":
		body.take_damage(damage)
