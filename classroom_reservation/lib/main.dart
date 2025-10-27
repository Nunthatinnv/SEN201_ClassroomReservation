// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Reservation {
  int id;
  String name;
  String room;
  String date; // 'yyyy-MM-dd'
  String time;
  String duration;

  Reservation({
    required this.id,
    required this.name,
    required this.room,
    required this.date,
    required this.time,
    required this.duration,
  });

  Reservation copyWith({
    int? id,
    String? name,
    String? room,
    String? date,
    String? time,
    String? duration,
  }) {
    return Reservation(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Reservations',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Reservation> reservations = [
    Reservation(
        id: 1,
        name: 'John Smith',
        room: 'Room A',
        date: '2025-10-28',
        time: '09:00-10:00',
        duration: '1 hour'),
    Reservation(
        id: 2,
        name: 'Jane Doe',
        room: 'Room B',
        date: '2025-10-28',
        time: '14:00-15:30',
        duration: '1.5 hours'),
    Reservation(
        id: 3,
        name: 'Bob Johnson',
        room: 'Room A',
        date: '2025-10-29',
        time: '10:00-12:00',
        duration: '2 hours'),
    Reservation(
        id: 4,
        name: 'Alice Williams',
        room: 'Room C',
        date: '2025-10-30',
        time: '11:00-12:00',
        duration: '1 hour'),
  ];

  bool showExportModal = false;
  String selectedDate = '2025-10-28'; // default, mirror original file

  // Helpers to format and generate month days
  String getMonthName() {
    final now = DateTime.now();
    return DateFormat.yMMMM().format(now);
  }

  List<_DayCell?> getCurrentMonthDays() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final firstOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstOfMonth.weekday % 7; // Monday=1 ... Sunday=0
    final totalDays = DateTime(year, month + 1, 0).day;

    final List<_DayCell?> days = [];

    // Add empty cells for days before month starts (Sunday-first grid)
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    for (int d = 1; d <= totalDays; d++) {
      final date = DateTime(year, month, d);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final hasReservation =
          reservations.any((r) => r.date == dateStr);
      days.add(_DayCell(day: d, date: dateStr, hasReservation: hasReservation));
    }

    return days;
  }

  List<Reservation> getReservationsForDate(String date) {
    return reservations.where((r) => r.date == date).toList();
  }

  // Add: open AddEdit screen in 'add' mode. Expecting Reservation returned or null.
  void handleAdd() async {
    final result = await Navigator.push<Reservation>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditReservationScreen(
          mode: 'add',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        // mimic Date.now() id
        final newRes = result.copyWith(id: DateTime.now().millisecondsSinceEpoch);
        reservations.add(newRes);
      });
    }
  }

  // Edit: open AddEdit screen with reservation prefilled. Expect updated reservation back.
  void handleEdit(Reservation reservation) async {
    final result = await Navigator.push<Reservation?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditReservationScreen(
          mode: 'edit',
          reservation: reservation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        reservations = reservations
            .map((r) => r.id == result.id ? result : r)
            .toList();
      });
    }
  }

  void handleDelete(int id) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: const Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                reservations.removeWhere((r) => r.id == id);
              });
              Navigator.pop(ctx, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void handleExport(String format) {
    setState(() => showExportModal = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting to $format format...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = getCurrentMonthDays();
    final selectedDateReservations = getReservationsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Reservations'),
        backgroundColor: const Color(0xFF6B8AA3),
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: handleAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('+ Add Reservation', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => showExportModal = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Export', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // Calendar + Reservations in a scrollable area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(getMonthName(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        // Weekday headers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                              .map((d) => Expanded(
                                    child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        // Grid (7 columns)
                        LayoutBuilder(builder: (context, constraints) {
                          final cellWidth = (constraints.maxWidth - 6) / 7;
                          return Wrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: calendarDays.map((dayInfo) {
                              final isSelected = dayInfo != null && dayInfo.date == selectedDate;
                              return GestureDetector(
                                onTap: dayInfo == null ? null : () {
                                  setState(() {
                                    selectedDate = dayInfo.date;
                                  });
                                },
                                child: Container(
                                  width: cellWidth,
                                  height: cellWidth,
                                  decoration: BoxDecoration(
                                    color: dayInfo == null
                                        ? const Color(0xFFFAFAFA)
                                        : isSelected
                                            ? const Color(0xFF6B8AA3)
                                            : dayInfo.hasReservation
                                                ? const Color(0xFFE3F2FD)
                                                : Colors.transparent,
                                    border: Border.all(color: const Color(0xFFF0F0F0)),
                                  ),
                                  child: dayInfo == null
                                      ? const SizedBox.shrink()
                                      : Stack(
                                          children: [
                                            Center(
                                              child: Text(
                                                '${dayInfo.day}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSelected ? Colors.white : Colors.black87,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (dayInfo.hasReservation)
                                              Positioned(
                                                bottom: 6,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF4CAF50),
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Reservations for Selected Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reservations for $selectedDate', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (selectedDateReservations.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Text('No reservations for this date', style: TextStyle(color: Colors.grey))),
                          )
                        else
                          Column(
                            children: selectedDateReservations.map((reservation) {
                              return _ReservationCard(
                                reservation: reservation,
                                onEdit: () => handleEdit(reservation),
                                onDelete: () => handleDelete(reservation.id),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  // All Reservations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        const Text('All Reservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Column(
                          children: reservations.map((reservation) {
                            return _ReservationCard(
                              reservation: reservation,
                              onEdit: () => handleEdit(reservation),
                              onDelete: () => handleDelete(reservation.id),
                              showDateAndRoom: true,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Export Modal bottom sheet
      bottomSheet: showExportModal ? _buildExportSheet() : null,
    );
  }

  Widget _buildExportSheet() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Export Format', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => handleExport('PDF'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('PDF'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => handleExport('Excel'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Excel (XLSX)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => handleExport('CSV'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('CSV'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => showExportModal = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell {
  final int day;
  final String date;
  final bool hasReservation;
  _DayCell({required this.day, required this.date, required this.hasReservation});
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDateAndRoom;

  const _ReservationCard({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onDelete,
    this.showDateAndRoom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reservation.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(showDateAndRoom ? '${reservation.room} • ${reservation.date}' : reservation.room, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text('${reservation.time} (${reservation.duration})', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800)),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
                  child: const Text('Delete'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// Simple Add/Edit screen
/// - mode: 'add' or 'edit'
/// - if edit, pass reservation to prefill
/// Returns a Reservation (new or updated) on Navigator.pop
class AddEditReservationScreen extends StatefulWidget {
  final String mode;
  final Reservation? reservation;

  const AddEditReservationScreen({super.key, required this.mode, this.reservation});

  @override
  State<AddEditReservationScreen> createState() => _AddEditReservationScreenState();
}

class _AddEditReservationScreenState extends State<AddEditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _durationCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _roomCtrl = TextEditingController(text: r?.room ?? '');
    _dateCtrl = TextEditingController(text: r?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _timeCtrl = TextEditingController(text: r?.time ?? '');
    _durationCtrl = TextEditingController(text: r?.duration ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.reservation?.id ?? DateTime.now().millisecondsSinceEpoch;
    final newRes = Reservation(
      id: id,
      name: _nameCtrl.text.trim(),
      room: _roomCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
    );

    Navigator.pop(context, newRes);
  }

  Future<void> _pickDate() async {
    DateTime initial;
    try {
      initial = DateFormat('yyyy-MM-dd').parse(_dateCtrl.text);
    } catch (_) {
      initial = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
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
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: 'Room'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter room' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeCtrl,
                decoration: const InputDecoration(labelText: 'Time (e.g. 09:00-10:00)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationCtrl,
                decoration: const InputDecoration(labelText: 'Duration (e.g. 1 hour)'),
              ),
              const SizedBox(height: 16),
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
