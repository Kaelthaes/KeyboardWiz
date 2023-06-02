class_name cyclops extends Enemy

var speed = 200  # The speed of the enemy
var player  # The player the enemy is chasing
var move_horizontally = true  # To alternate between horizontal and vertical movement
var active = false

func _ready():
	player = get_node('/root/Floor1/Character')  # Replace with the path to your player node

func _physics_process(delta):
	var direction = player.global_position - global_position
	
	#basically, if it gets within 2000 pixels of you, it activates and chases you until you die.
	if direction.distance_to(Vector2(0,0)) > 1000:
		active = true
	if !active:
		return
	direction = direction.normalized()  # Normalize the direction
	if move_horizontally:
		if direction.x > 0:
			direction = Vector2(1, 0)  # Right
		else:
			direction = Vector2(-1, 0)  # Left
	else:
		if direction.y > 0:
			direction = Vector2(0, 1)  # Down
		else:
			direction = Vector2(0, -1)  # Up

	var new_position = global_position + direction * speed * delta
	move_and_collide(direction * speed)
	if global_position.distance_to(player.global_position) < speed * delta:
		move_horizontally = not move_horizontally
