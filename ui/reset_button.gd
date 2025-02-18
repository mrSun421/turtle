extends Button


func _button_pressed() -> void:
	EventBus.emit_signal("reset_turtle")


func _ready() -> void:
	self.button_down.connect(self._button_pressed)
