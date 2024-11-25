extends Node3D
class_name Turtle

const TWEEN_LENGTH = 0.5
const WAIT_TIME = 0.5

var heading: Vector3 = Vector3(1, 0, 0)
var normal: Vector3 = Vector3(0, 1, 0)

var turtle_actions = []
var visual_cylinders = []

func executeMove(distance: float) -> void:
	var pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var current_position = self.position
	var future_position = current_position + distance * heading

	pos_tween.tween_property(self, "position", future_position, TWEEN_LENGTH)

func executeTurn(angle: float) -> void:
	var angle_in_rad = deg_to_rad(angle)
	var new_heading = self.heading.rotated(normal, angle_in_rad)
	var new_quaternion_representation = Quaternion(self.heading, new_heading)
	var heading_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	heading_tween.tween_property(self, "quaternion", self.quaternion * new_quaternion_representation, TWEEN_LENGTH)
	self.heading = new_heading.normalized()

func executeRoll(angle: float) -> void:
	# TODO: WTF? It's not rotating correctly, fix this!
	var angle_in_rad = deg_to_rad(angle)
	var new_normal = self.normal.rotated(heading, angle_in_rad)
	var new_quaternion_representation = Quaternion(self.normal, new_normal)
	var normal_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	normal_tween.tween_property(self, "quaternion", self.quaternion * new_quaternion_representation, TWEEN_LENGTH)
	self.normal = new_normal.normalized()


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
		else:
			print("Action Something went wrong")
		
		await get_tree().create_timer(WAIT_TIME).timeout


func _ready() -> void:
	for _i in range(3):
		self.turtle_actions.append(MoveAction.new(3))
		self.turtle_actions.append(RollAction.new(120))

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
