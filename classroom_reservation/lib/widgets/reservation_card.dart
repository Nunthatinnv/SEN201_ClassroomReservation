import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDateAndRoom;

  const ReservationCard({
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
