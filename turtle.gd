extends Node3D
class_name Turtle

signal moving(current_pos: Vector3)
signal finished_move(pos1: Vector3, pos2: Vector3)
signal finished_resetting

var tween_time = 0.5
var wait_time = 0.2


var turtle_actions = []
var turtle_event_queue = []
var is_moving = false
var is_running = false
var reset_was_pressed = false
var current_tween: Tween

func execute_move(distance: float) -> Tween:
	var pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var current_position = self.position
	var future_position = current_position + distance * self.basis.x

	pos_tween.tween_property(self, "position", future_position, tween_time)
	return pos_tween


func execute_turn(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(normal, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, tween_time)
	return rotation_tween

func execute_roll(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(heading, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, tween_time)
	return rotation_tween

func execute_dive(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var left: Vector3 = self.basis.z
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(left, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, tween_time)
	return rotation_tween
	
func execute_turtle_actions():
	turtle_event_queue.append_array(turtle_actions)

	while !turtle_event_queue.is_empty():
		var current_position = self.position
		var current_action = turtle_event_queue.pop_front()
		current_tween = self._execute_turtle_action(current_action, current_position)
		await current_tween.finished
		if current_action is MoveAction:
			is_moving = false
			finished_move.emit(current_position, self.position)

		await get_tree().create_timer(wait_time).timeout
	
		
func _execute_turtle_action(action, current_position) -> Tween:
	if action is MoveAction:
		is_moving = true
		moving.emit(current_position)
		var m_action: MoveAction = action as MoveAction
		return self.execute_move(m_action.distance)
	elif action is TurnAction:
		var t_action: TurnAction = action as TurnAction
		return self.execute_turn(t_action.angle)
	elif action is RollAction:
		var r_action: RollAction = action as RollAction
		return self.execute_roll(r_action.angle)
	elif action is DiveAction:
		var d_action: DiveAction = action as DiveAction
		return self.execute_dive(d_action.angle)
	else:
		print("Action Something went wrong")
	return

		
func _on_start_button_pressed() -> void:
	if is_running:
		return
	is_running = true
	self.execute_turtle_actions()


func append_turtle_actions(actions):
	if actions is Array:
		turtle_actions.append_array(actions)
		return
	if actions is MoveAction or actions is TurnAction or actions is RollAction or actions is DiveAction:
		turtle_actions.append(actions)
		return


func _on_reset_button_pressed() -> void:
	turtle_event_queue.clear()
	is_running = false
	is_moving = false
	if current_tween:
		current_tween.finished.emit()
		current_tween.kill()
	self.position = Vector3.ZERO
	self.basis = Basis.IDENTITY


func _on_wait_time_input_value_changed(value: float) -> void:
	wait_time = value / 1000


func _on_tween_time_input_value_changed(value: float) -> void:
	tween_time = value / 1000


class MoveAction:
	var distance: float
	func _init(set_distance: float = 0.0) -> void:
		self.distance = set_distance

class TurnAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle

class RollAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle

class DiveAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle
