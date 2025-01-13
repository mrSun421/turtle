extends Node

const port = 21327

var server: TCPServer = TCPServer.new()
var streams: Array[StreamPeerTCP]

func _init() -> void:
	var err = server.listen(21327)
	if err != OK:
		print_debug("server failed to start listening on port %d!" % port)
	print("server listening on %d" % server.get_local_port())

func _process(delta: float) -> void:
	print(len(streams))
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
					print(text_data)
					stream.put_data(text_data.to_upper().to_ascii_buffer())
		else:
			streams[i].disconnect_from_host()
			streams.remove_at(i)
			break
			

	if server.is_connection_available():
		var newStream = server.take_connection()
		newStream.set_no_delay(true)
		streams.append(newStream)
		print("took connection")
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var iek_event = event as InputEventKey