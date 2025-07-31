extends Node

signal server_started
signal server_stopped
signal client_connected(peer_id)
signal client_disconnected(peer_id)

var peer: ENetMultiplayerPeer

const DEFAULT_PORT := 7777

func host_game(port := DEFAULT_PORT):
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, 2)
	if result != OK:
		push_error("Failed to start server on port %s" % port)
		return
	multiplayer.multiplayer_peer = peer
	server_started.emit()
	print("Server started on port", port)

func join_game(ip: String, port := DEFAULT_PORT):
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		push_error("Failed to connect to server %s:%s" % [ip, port])
		return
	multiplayer.multiplayer_peer = peer
	print("Client connecting to server at", ip, ":", port)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	print("Client connected:", id)
	client_connected.emit(id)

func _on_peer_disconnected(id):
	print("Client disconnected:", id)
	client_disconnected.emit(id)
