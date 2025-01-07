extends SpinBox

@onready var le: LineEdit = self.get_line_edit()

func _ready() -> void:
	le.connect("text_submitted", _on_text_submitted)

func _on_text_submitted(new_text: String) -> void:
	le.release_focus()
