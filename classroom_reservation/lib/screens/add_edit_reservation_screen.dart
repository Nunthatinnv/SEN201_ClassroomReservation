import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../models/room.dart';

// Add/Edit screen
class AddEditReservationScreen extends StatefulWidget {
  final String mode; // 'add' or 'edit'
  final Reservation? reservation;
  final List<Room> rooms; 

  const AddEditReservationScreen({super.key, required this.mode, this.reservation, required this.rooms});

  @override
  State<AddEditReservationScreen> createState() => _AddEditReservationScreenState();
}

class _AddEditReservationScreenState extends State<AddEditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomCtrl;
  late TextEditingController _competencyCtrl;
  late TextEditingController _repetitionCtrl;
  late TextEditingController _capacityCtrl;
  late DateTime _timeStart;
  late DateTime _timeEnd;
  
  
  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    _roomCtrl = TextEditingController(text: r?.roomId ?? '');
    _competencyCtrl = TextEditingController(text: r?.competency ?? '');
    _repetitionCtrl = TextEditingController(text: '1');
    _capacityCtrl = TextEditingController(text: '1');
    _timeStart = r?.timeStart ?? DateTime.now();
    _timeEnd = r?.timeEnd ?? DateTime.now();
    

  }

  @override
  void dispose() {
    _roomCtrl.dispose();
    _competencyCtrl.dispose();
    _repetitionCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose(); // Always call super.dispose() last
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newRes = Reservation(
      seriesId: '', // generate or leave empty for now
      roomId: _roomCtrl.text.trim(),
      timeStart: _timeStart,
      timeEnd: _timeEnd,
      competency: _competencyCtrl.text.trim(),
    );

    final repetition = int.tryParse(_repetitionCtrl.text.trim()) ?? 1;
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 1;

    Navigator.pop(
      context,
       ReservationInput(reservation: newRes, repetition: repetition, capacity: capacity));
  }

  Future<void> _pickDateTimeRange() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _timeStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timeStart),
    );
    if (startTime == null) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timeEnd),
    );
    if (endTime == null) return;

    setState(() {
      _timeStart = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, startTime.hour, startTime.minute);
      _timeEnd = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, endTime.hour, endTime.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == 'edit';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Reservation' : 'Add Reservation'),
        backgroundColor: const Color(0xFF6B8AA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Competency / Name
              TextFormField(
                controller: _competencyCtrl,
                decoration: const InputDecoration(labelText: 'Competency'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a name or competency'
                    : null,
              ),
              const SizedBox(height: 8),

              // Room ID
              TextFormField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: 'Room ID'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a room ID';
                  }
                  if (!widget.rooms.contains(value.trim())) {
                    return 'Room does not exist in system';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Time range
              ListTile(
                title: Text(
                  'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_timeStart)} - ${DateFormat('HH:mm').format(_timeEnd)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTimeRange,
              ),
              const SizedBox(height: 8),

              // Repetition (number only)
              TextFormField(
                controller: _repetitionCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Repetition'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter repetition';
                  if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // capacity (number only)
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
              const SizedBox(height: 16),

              // Save button
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
