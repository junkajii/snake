extends Node

onready var Score_Label = $Score/Label
onready var Apple_Crunch = $Apple_Crunch

const SNAKE = 0
const APPLE = 1

var apple_pos : Vector2
var snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10),]
var snake_direction = Vector2(1, 0)
var add_apple = false


func _ready() -> void:
	apple_pos = place_apple()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('player_move_up') and not snake_direction == Vector2(0, 1):
		snake_direction = Vector2(0, -1)
	if Input.is_action_just_pressed('player_move_down') and not snake_direction == Vector2(0, -1):
		snake_direction = Vector2(0, 1)
	if Input.is_action_just_pressed('player_move_right') and not snake_direction == Vector2(-1, 0):
		snake_direction = Vector2(1, 0)
	if Input.is_action_just_pressed('player_move_left') and not snake_direction == Vector2(1, 0):
		snake_direction = Vector2(-1, 0)


func _process(_delta: float) -> void:
	check_game_over()
	if apple_pos in snake_body:
		apple_pos = place_apple()


func place_apple() -> Vector2:
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	return Vector2(x, y)


func draw_apple() -> void:
	$Snake_Apple.set_cell(apple_pos.x, apple_pos.y, APPLE)


func draw_snake() -> void:
	for block_index in snake_body.size():
		var block = snake_body[block_index]

		if block_index == 0:
			var head_dir = relation2(snake_body[0], snake_body[1])
			if head_dir == 'up':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(3, 0))
			if head_dir == 'down':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(3, 0))
			if head_dir == 'right':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(2, 0))
			if head_dir == 'left':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(2, 0))
		elif block_index == snake_body.size() -1:
			var tail_dir = relation2(snake_body[-1], snake_body[-2])
			if tail_dir == 'up':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(1, 1))
			if tail_dir == 'down':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(1, 1))
			if tail_dir == 'right':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(1, 0))
			if tail_dir == 'left':
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(1, 0))
		else:
			var previous_block = snake_body[block_index - 1] - block
			var next_block = snake_body[block_index + 1] - block

			if previous_block.x == next_block.x:
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(4, 1))
			elif previous_block.y == next_block.y:
				$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(4, 0))
			else:
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1: # LEFT TOP
					$Snake_Apple.set_cell(block.x, block.y, SNAKE, true, true, false, Vector2(5, 0))
				if previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1: # RIGHT TOP
					$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, true, false, Vector2(5, 0))
				if previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1: # LEFT DOWN
					$Snake_Apple.set_cell(block.x, block.y, SNAKE, true, false, false, Vector2(5, 0))
				if previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1: # RIGHT DOWN
					$Snake_Apple.set_cell(block.x, block.y, SNAKE, false, false, false, Vector2(5, 0))


func relation2(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(0, -1): return 'up'
	if block_relation == Vector2(0, 1): return 'down'
	if block_relation == Vector2(1, 0): return 'right'
	if block_relation == Vector2(-1, 0): return 'left'


func move_snake() -> void:
	if add_apple:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy
		add_apple = false
	else:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 2)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy


func delete_tiles(id: int) -> void:
	var cells = $Snake_Apple.get_used_cells_by_id(id)
	for cell in cells:
		$Snake_Apple.set_cell(cell.x, cell.y, -1)


func check_apple_eaten() -> void:
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apple = true
		Score_Label.update_score()
		Apple_Crunch.play()


func check_game_over() -> void:
	var head = snake_body[0]
	if head.x > 19 or head.x < 0 or head.y > 19 or head.y < 0:
		reset()

	for block in snake_body.slice(1, snake_body.size() - 1):
		if block == head:
			reset()

func reset() -> void:
	get_tree().reload_current_scene()


func _on_Snake_Tick_timeout() -> void:
	move_snake()
	draw_apple()
	draw_snake()
	check_apple_eaten()
