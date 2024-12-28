extends Node3D
class_name Turtle

const TWEEN_TIME = 0.5
const WAIT_TIME = 0.2


var turtle_actions = []
var visual_cylinders = []

func execute_move(distance: float) -> Tween:
	var pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var current_position = self.position
	var future_position = current_position + distance * self.basis.x

	pos_tween.tween_property(self, "position", future_position, TWEEN_TIME)
	return pos_tween


func execute_turn(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(normal, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	return rotation_tween

func execute_roll(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(heading, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	return rotation_tween

func execute_dive(angle: float) -> Tween:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var left: Vector3 = self.basis.z
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(left, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	return rotation_tween
	
func execute_turtle_action():
	for action in turtle_actions:
		var current_tween: Tween
		var current_position = self.position
		if action is MoveAction:
			var m_action: MoveAction = action as MoveAction
			current_tween = self.execute_move(m_action.distance)
		elif action is TurnAction:
			var t_action: TurnAction = action as TurnAction
			current_tween = self.execute_turn(t_action.angle)
		elif action is RollAction:
			var r_action: RollAction = action as RollAction
			current_tween = self.execute_roll(r_action.angle)
		elif action is DiveAction:
			var d_action: DiveAction = action as DiveAction
			current_tween = self.execute_dive(d_action.angle)
		else:
			print("Action Something went wrong")
		

		await current_tween.finished
		if action is MoveAction:
			Draw3D.point(current_position)
			Draw3D.line(current_position, self.position)
			Draw3D.point(self.position)
		await get_tree().create_timer(WAIT_TIME).timeout


func _ready() -> void:
	for _i in range(3):
		self.turtle_actions.append(MoveAction.new(3))
		self.turtle_actions.append(DiveAction.new(120))


func _on_start_button_pressed() -> void:
	self.execute_turtle_action()


func _on_reset_button_pressed() -> void:
	# TODO: Implement reset, Involes refactoring line and point creating logic
	pass


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
