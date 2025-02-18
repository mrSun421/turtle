extends Node3D
class_name Turtle

signal moving(current_pos: Vector3)
signal finished_move(pos1: Vector3, pos2: Vector3)

var tween_time = 0.5
var wait_time = 0.2


var turtle_actions = []
var turtle_event_queue = []
var is_moving = false
var is_running = false
var reset_was_pressed = false
var pen_is_down = true
var line_color: Color = Color.WHITE_SMOKE
var current_tween: Tween

func set_line_color_rgb8(r, g, b):
	line_color = Color8(r, g, b)
func set_line_color_rgbfloat(r, g, b):
	line_color = Color(r, g, b)
func set_line_color_string(colorString):
	line_color = Color.from_string(colorString, Color.WHITE_SMOKE)

func execute_move(distance: float) -> Tween:
	var pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var current_position = self.position
	var future_position = current_position + distance * self.basis.x

	pos_tween.tween_property(self, "position", future_position, tween_time)
	return pos_tween


func execute_yaw(angle: float) -> Tween:
	var _heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(normal, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, tween_time)
	return rotation_tween

func execute_roll(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var _normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(heading, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, tween_time)
	return rotation_tween

func execute_pitch(angle: float) -> Tween:
	var _heading: Vector3 = self.basis.x
	var _normal: Vector3 = self.basis.y
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
		if current_tween:
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
	elif action is YawAction:
		var t_action: YawAction = action as YawAction
		return self.execute_yaw(t_action.angle)
	elif action is RollAction:
		var r_action: RollAction = action as RollAction
		return self.execute_roll(r_action.angle)
	elif action is PitchAction:
		var d_action: PitchAction = action as PitchAction
		return self.execute_pitch(d_action.angle)
	elif action is PenUpAction:
		pen_is_down = false
	elif action is PenDownAction:
		pen_is_down = true
	elif action is ColorAction:
		var c_action: ColorAction = action as ColorAction
		line_color = c_action.color
	else:
		print("Action Something went wrong")
	return

		
func _on_start_turtle_signal() -> void:
	if is_running:
		return
	is_running = true
	self.execute_turtle_actions()


func append_turtle_actions(actions):
	if actions is Array:
		turtle_actions.append_array(actions)
		return
	else:
		turtle_actions.append(actions)
		return


func _on_reset_turtle_signal() -> void:
	turtle_event_queue.clear()
	is_running = false
	is_moving = false
	if current_tween:
		current_tween.finished.emit()
		current_tween.kill()
	self.position = Vector3.ZERO
	self.basis = Basis.IDENTITY
	pen_is_down = true
	line_color = Color.WHITE_SMOKE


func _on_wait_time_input_value_changed(value: float) -> void:
	print(value)
	wait_time = value / 1000


func _on_tween_time_input_value_changed(value: float) -> void:
	tween_time = value / 1000


class MoveAction:
	var distance: float
	func _init(set_distance: float = 0.0) -> void:
		self.distance = set_distance

class YawAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle

class RollAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle

class PitchAction:
	var angle: float
	func _init(set_angle: float = 0.0) -> void:
		self.angle = set_angle

class PenUpAction:
	func _init() -> void:
		pass

class PenDownAction:
	func _init() -> void:
		pass

class ColorAction:
	var color: Color
	func _init(set_color: Color = Color.WHITE_SMOKE) -> void:
		self.color = set_color

func _ready() -> void:
	EventBus.connect("start_turtle", self._on_start_turtle_signal)
	EventBus.connect("reset_turtle", self._on_reset_turtle_signal)
	EventBus.connect("wait_time_changed", self._on_wait_time_input_value_changed)
	EventBus.connect("tween_time_changed", self._on_tween_time_input_value_changed)