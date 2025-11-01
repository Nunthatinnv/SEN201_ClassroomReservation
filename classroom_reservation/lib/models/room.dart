class Room {
  String roomId;
  String? roomName;
  int capacity;
  String? equipments;

  Room({
    required this.roomId,
    this.roomName,
    required this.capacity,
    this.equipments,
  });

  // Convert Room object to Map (for insert/update)
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'room_name': roomName,
      'capacity': capacity,
      'equipments': equipments,
    };
  }

  // Convert Map to Room object (for query)
  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      roomId: map['room_id'],
      roomName: map['room_name'],
      capacity: map['capacity'],
      equipments: map['equipments'],
    );
  }
}
