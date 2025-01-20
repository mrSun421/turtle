extends Node

const port = 21327

var server: TCPServer = TCPServer.new()
var streams: Array[StreamPeerTCP]
@export var turtle: Turtle

func _init() -> void:
	var err = server.listen(21327)
	if err != OK:
		print_debug("server failed to start listening on port %d!" % port)
	print("server listening on %d" % server.get_local_port())

func _process(delta: float) -> void:
	for i in len(streams):
		var stream = streams[i]
		if stream.poll() != OK:
			break
		var status = stream.get_status()
		if status == stream.STATUS_CONNECTED:
			var available_bytes = stream.get_available_bytes()
			if available_bytes > 0:
				# var data = stream.get_data(available_bytes)
				var text_data = stream.get_utf8_string(available_bytes)
				if text_data:
					var json_data = JSON.parse_string(text_data)
					for j in len(json_data):
						var curr_data = json_data[j]
						match curr_data["type"]:
							"color":
								var col_dat = curr_data["color"]
								var col = Color(col_dat["r"], col_dat["g"], col_dat["b"])
								turtle.append_turtle_actions(Turtle.ColorAction.new(col))
							"move":
								turtle.append_turtle_actions(Turtle.MoveAction.new(curr_data["value"]))
							"yaw":
								turtle.append_turtle_actions(Turtle.YawAction.new(curr_data["value"]))
							"pitch":
								turtle.append_turtle_actions(Turtle.PitchAction.new(curr_data["value"]))
							"roll":
								turtle.append_turtle_actions(Turtle.RollAction.new(curr_data["value"]))
							"penup":
								turtle.append_turtle_actions(Turtle.PenUpAction.new())
							"pendown":
								turtle.append_turtle_actions(Turtle.PenDownAction.new())
							_:
								print("unknown action type: %s" % curr_data["type"])
					var confirmation_string = "data recieved: %s bytes" % available_bytes
					stream.put_data(confirmation_string.to_ascii_buffer())
		else:
			streams[i].disconnect_from_host()
			streams.remove_at(i)
			break
			

	if server.is_connection_available():
		var newStream = server.take_connection()
		newStream.set_no_delay(true)
		streams.append(newStream)
		print("took connection")
