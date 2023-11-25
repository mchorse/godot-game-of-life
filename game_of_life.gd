extends Node2D

@onready var tile_map: TileMap = $Cells
@onready var timer: Timer = $CycleTimer
@onready var label_score: Label = $CanvasLayer/HUD/Score
@onready var preview: Sprite2D = $Preview

var score = 0

func update_label():
	label_score.text = str(score)

func _on_cycle_timer_timeout():
	update_cells()

func _input(event):
	if Input.is_action_just_released("click"): # Place 
		var mouse_pos = get_viewport().get_mouse_position()
		var tile_pos = tile_map.local_to_map(mouse_pos)
		var tile = tile_map.get_cell_source_id(0, tile_pos)
		
		tile_map.set_cell(0, tile_pos, 0 if tile == -1 else -1, Vector2i.ZERO)
	elif Input.is_action_just_pressed("plause"):
		timer.paused = not timer.paused

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var tile_pos = tile_map.local_to_map(mouse_pos)
	
	mouse_pos = tile_map.map_to_local(tile_pos)
	
	preview.global_position = mouse_pos

func update_cells():
	var rect = tile_map.get_used_rect()
	var to_alive = []
	var to_kill = []
	
	for x in range(rect.size.x + 2):
		for y in range(rect.size.y + 2):
			var vector = Vector2i(x + rect.position.x - 1, y + rect.position.y - 1)
			var tile = tile_map.get_cell_source_id(0, vector)
			var count = count_neighbors(vector.x, vector.y)
			var alive = tile >= 0
			
			if alive and count < 2:
				to_kill.append(vector)
			elif alive and (count == 2 or count == 3):
				pass
			elif alive and count > 3:
				to_kill.append(vector)
			elif not alive and count == 3:
				to_alive.append(vector)
	
	for alive in to_alive:
		tile_map.set_cell(0, alive, 0, Vector2i.ZERO)
		score += 1
	
	for kill in to_kill:
		tile_map.set_cell(0, kill, -1)
	
	update_label()

func count_neighbors(x, y) -> int:
	return has_cell(x - 1, y) + has_cell(x + 1, y) + has_cell(x, y - 1) + has_cell(x, y + 1) + has_cell(x - 1, y - 1) + has_cell(x + 1, y - 1) + has_cell(x - 1, y + 1) + has_cell(x + 1, y + 1) 

func has_cell(x, y) -> int:
	return 0 if tile_map.get_cell_source_id(0, Vector2i(x, y)) == -1 else 1
