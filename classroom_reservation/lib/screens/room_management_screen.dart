import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/database_services/room_services.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final RoomServices roomServices = RoomServices();
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    final result = await roomServices.getAllRooms();
    if (result['success']) {
      setState(() {
        rooms = (result['rooms'] as List<Room>);
      });
    } else {
      debugPrint('Error loading rooms: ${result['error']}');
    }
  }

  Future<void> handleAdd() async {
    final newRoom = await Navigator.push<Room>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditRoomScreen(mode: 'add'),
      ),
    );

    if (newRoom != null) {
      final result = await roomServices.createRoom(newRoom);
      if (result['success']) {
        await loadRooms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    }
  }

  Future<void> handleEdit(Room room) async {
    final updatedRoom = await Navigator.push<Room>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRoomScreen(mode: 'edit', room: room),
      ),
    );

    if (updatedRoom != null) {
      final result = await roomServices.updateRoom(updatedRoom.roomId, room.toMap());
      if (result['success']) {
        await loadRooms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    }
  }

  Future<void> handleDelete(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete "${room.roomName ?? room.roomId}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await roomServices.deleteRoom(room.roomId);
      if (result['success']) await loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        backgroundColor: const Color(0xFF6B8AA3),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleAdd(),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
      body: rooms.isEmpty
          ? const Center(child: Text('No rooms available', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.roomName ?? room.roomId,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('ID: ${room.roomId}', style: const TextStyle(color: Colors.grey)),
                            Text('Capacity: ${room.capacity}', style: const TextStyle(color: Colors.grey)),
                            if (room.equipments != null && room.equipments!.isNotEmpty)
                              Text('Equipments: ${room.equipments}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => handleEdit(room),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => handleDelete(room),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddEditRoomScreen extends StatefulWidget {
  final String mode; // 'add' or 'edit'
  final Room? room;

  const AddEditRoomScreen({super.key, required this.mode, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomIdCtrl;
  late TextEditingController _roomNameCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _equipmentsCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _roomIdCtrl = TextEditingController(text: r?.roomId ?? '');
    _roomNameCtrl = TextEditingController(text: r?.roomName ?? '');
    _capacityCtrl = TextEditingController(text: r?.capacity.toString() ?? '');
    _equipmentsCtrl = TextEditingController(text: r?.equipments ?? '');
  }

  @override
  void dispose() {
    _roomIdCtrl.dispose();
    _roomNameCtrl.dispose();
    _capacityCtrl.dispose();
    _equipmentsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newRoom = Room(
      roomId: _roomIdCtrl.text.trim(),
      roomName: _roomNameCtrl.text.trim().isEmpty ? null : _roomNameCtrl.text.trim(),
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 0,
      equipments: _equipmentsCtrl.text.trim().isEmpty ? null : _equipmentsCtrl.text.trim(),
    );

    Navigator.pop(context, newRoom);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == 'edit';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Room' : 'Add Room'),
        backgroundColor: const Color(0xFF6B8AA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomIdCtrl,
                decoration: const InputDecoration(labelText: 'Room ID'),
                enabled: !isEdit,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a room ID'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roomNameCtrl,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter capacity';
                  if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _equipmentsCtrl,
                decoration: const InputDecoration(labelText: 'Equipments (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
