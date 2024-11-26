extends Node3D
class_name Turtle

const TWEEN_TIME = 0.5
const WAIT_TIME = 0.0


var turtle_actions = []
var visual_cylinders = []

func executeMove(distance: float) -> void:
	var pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var current_position = self.position
	var future_position = current_position + distance * self.basis.x

	pos_tween.tween_property(self, "position", future_position, TWEEN_TIME)
	await pos_tween.finished


func executeTurn(angle: float) -> void:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(normal, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	await rotation_tween.finished

func executeRoll(angle: float) -> void:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(heading, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	await rotation_tween.finished

func executeDive(angle: float) -> void:
	var heading: Vector3 = self.basis.x
	var normal: Vector3 = self.basis.y
	var left: Vector3 = self.basis.z
	var angle_in_rad = deg_to_rad(angle)
	var quaternion_rotation = Quaternion(left, angle_in_rad)
	var rotation_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_property(self, "quaternion", self.quaternion * quaternion_rotation, TWEEN_TIME)
	await rotation_tween.finished
	
func executeTurtleActions():
	for action in turtle_actions:
		if action is MoveAction:
			var m_action: MoveAction = action as MoveAction
			self.executeMove(m_action.distance)
		elif action is TurnAction:
			var t_action: TurnAction = action as TurnAction
			self.executeTurn(t_action.angle)
		elif action is RollAction:
			var r_action: RollAction = action as RollAction
			self.executeRoll(r_action.angle)
		elif action is DiveAction:
			var d_action: DiveAction = action as DiveAction
			self.executeDive(d_action.angle)
		else:
			print("Action Something went wrong")
		
		await get_tree().create_timer(WAIT_TIME + TWEEN_TIME).timeout


func _ready() -> void:
	for _i in range(3):
		self.turtle_actions.append(MoveAction.new(3))
		self.turtle_actions.append(DiveAction.new(120))

	self.executeTurtleActions()


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
