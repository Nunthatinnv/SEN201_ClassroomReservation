import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/database_services/reservation_services.dart';
import 'services/database_services/series_services.dart';
import 'services/reservation_controller.dart';
import 'models/daycell.dart';
import 'models/reservation.dart'; // Reservation model for DB

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Reservations',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
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
  final ReservationServices reservationServices = ReservationServices();
  final SeriesServices seriesServices = SeriesServices();

  List<Reservation> reservations = [];
  bool showExportModal = false;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    final result = await reservationServices.getAllReservations();
    if (result['success']) {
      setState(() {
        reservations = (result['reservations'] as List<Reservation>?) ?? [];
      });
    } else {
      print('Error loading reservations: ${result['error']}');
    }
  }

  List<DayCell?> getCurrentMonthDays() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  final firstOfMonth = DateTime(year, month, 1);
  final firstWeekday = firstOfMonth.weekday % 7; // Sunday=0
  final totalDays = DateTime(year, month + 1, 0).day;

  final List<DayCell?> days = [];

  for (int i = 0; i < firstWeekday; i++) days.add(null);

  for (int d = 1; d <= totalDays; d++) {
    final date = DateTime(year, month, d);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final hasReservation = reservations.any((r) =>
        DateFormat('yyyy-MM-dd').format(r.timeStart) == dateStr);
    days.add(DayCell(day: d, date: dateStr, hasReservation: hasReservation));
  }
  return days;
}

List<Reservation> getReservationsForDate(String date) {
  return reservations
      .where((r) => DateFormat('yyyy-MM-dd').format(r.timeStart) == date)
      .toList();
}


  Future<void> handleAdd() async {
    final input = await Navigator.push<ReservationInput>(
      context,
      MaterialPageRoute(builder: (_) => AddEditReservationScreen(mode: 'add')),
    );

    if (input != null) {
      bool success = await addReservation(
        reservationServices,
        seriesServices,
        input.reservation.roomId,
        input.reservation.timeStart,
        input.reservation.timeEnd,
        input.capacity,
        input.repetition,
        input.reservation.competency,
      );

      if (success) await loadReservations();
    }
  }


  Future<void> handleEdit(Reservation reservation) async {
    final input = await Navigator.push<ReservationInput>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditReservationScreen(
          mode: 'edit',
          reservation: reservation,
        ),
      ),
    );

    if (input != null) {
      bool success = await editReservation(
        reservationServices,
        seriesServices,
        reservation.seriesId,        // existing seriesId
        input.reservation.roomId,    // updated roomId
        input.reservation.timeStart, // updated timeStart
        input.reservation.timeEnd,   // updated timeEnd
        input.capacity,              // updated capacity
        input.repetition,            // updated repetition
        input.reservation.competency // updated competency
      );

      if (success) await loadReservations();
    }
  }


  Future<void> handleDelete(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: const Text('Are you sure you want to delete all reservation which have same series with this reservation?'),
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
      bool success = await deleteReservation(
        reservationServices,
        seriesServices,
        reservation.seriesId, // use seriesId to delete the entire series
      );

      if (success) await loadReservations();
    }
  }


  @override
  Widget build(BuildContext context) {
    final calendarDays = getCurrentMonthDays();
    final selectedDateReservations = getReservationsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Room Reservations'), backgroundColor: const Color(0xFF6B8AA3)),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: handleAdd,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('+ Add Reservation'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => showExportModal = true),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Export'),
                  ),
                ),
              ],
            ),
          ),
          // Calendar and reservation list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Text(DateFormat.yMMMM().format(DateTime.now()), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                              .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(builder: (context, constraints) {
                          final cellWidth = (constraints.maxWidth - 6) / 7;
                          return Wrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: calendarDays.map((dayInfo) {
                              final isSelected = dayInfo != null && dayInfo.date == selectedDate;
                              return GestureDetector(
                                onTap: dayInfo == null ? null : () => setState(() => selectedDate = dayInfo.date),
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

                  // Selected date reservations
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
                                onDelete: () => handleDelete(reservation),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  // All reservations
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text('All Reservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  //       const SizedBox(height: 8),
                  //       Column(
                  //         children: reservations.map((reservation) {
                  //           return _ReservationCard(
                  //             reservation: reservation,
                  //             onEdit: () => handleEdit(reservation),
                  //             onDelete: () => handleDelete(reservation),
                  //             showDateAndRoom: true,
                  //           );
                  //         }).toList(),
                  //       ),
                  //       const SizedBox(height: 20),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            // const SizedBox(height: 12),
            // ElevatedButton(onPressed: () {}, child: const Text('PDF'), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48))),
            // const SizedBox(height: 8),
            // ElevatedButton(onPressed: () {}, child: const Text('Excel (XLSX)'), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48))),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: const Text('CSV'), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48))),
            // const SizedBox(height: 8),
            // TextButton(onPressed: () => setState(() => showExportModal = false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.competency,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            showDateAndRoom
                ? '${reservation.roomId} • ${DateFormat('yyyy-MM-dd').format(reservation.timeStart)}'
                : reservation.roomId,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            '${DateFormat('HH:mm').format(reservation.timeStart)} - ${DateFormat('HH:mm').format(reservation.timeEnd)}',
            style: const TextStyle(color: Colors.grey),
          ),
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
          ),
        ],

      ),
    );
  }
}

/// Add/Edit screen
class AddEditReservationScreen extends StatefulWidget {
  final String mode; // 'add' or 'edit'
  final Reservation? reservation;

  const AddEditReservationScreen({super.key, required this.mode, this.reservation});

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
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a room ID'
                    : null,
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

