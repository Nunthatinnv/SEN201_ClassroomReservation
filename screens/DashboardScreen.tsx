import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert, Modal } from 'react-native';

export default function DashboardScreen({ route, navigation }: {route: any, navigation: any}) {
  
  // Sample reservation data
  const [reservations, setReservations] = useState([
    { id: 1, name: 'John Smith', room: 'Room A', date: '2025-10-28', time: '09:00-10:00', duration: '1 hour' },
    { id: 2, name: 'Jane Doe', room: 'Room B', date: '2025-10-28', time: '14:00-15:30', duration: '1.5 hours' },
    { id: 3, name: 'Bob Johnson', room: 'Room A', date: '2025-10-29', time: '10:00-12:00', duration: '2 hours' },
    { id: 4, name: 'Alice Williams', room: 'Room C', date: '2025-10-30', time: '11:00-12:00', duration: '1 hour' },
  ]);

  const [showExportModal, setShowExportModal] = useState(false);
  const [selectedDate, setSelectedDate] = useState('2025-10-28');

  // Get current month calendar days
  const getCurrentMonthDays = () => {
    const days = [];
    const currentDate = new Date();
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    
    // Get first day of month and total days
    const firstDay = new Date(year, month, 1).getDay();
    const totalDays = new Date(year, month + 1, 0).getDate();
    
    // Add empty cells for days before month starts
    for (let i = 0; i < firstDay; i++) {
      days.push(null);
    }
    
    // Add all days of the month
    for (let day = 1; day <= totalDays; day++) {
      const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
      const hasReservation = reservations.some(r => r.date === dateStr);
      days.push({ day, date: dateStr, hasReservation });
    }
    
    return days;
  };

  const getMonthName = () => {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[new Date().getMonth()] + ' ' + new Date().getFullYear();
  };

  const getReservationsForDate = (date: any) => {
    return reservations.filter(r => r.date === date);
  };

  const handleAdd = () => {
    navigation.navigate('AddEditReservation', { 
      mode: 'add',
      onSave: (newReservation: any) => {
        setReservations([...reservations, { ...newReservation, id: Date.now() }]);
      }
    });
  };

  const handleEdit = (reservation: any) => {
    navigation.navigate('AddEditReservation', { 
      mode: 'edit',
      reservation: reservation,
      onSave: (updatedReservation: any) => {
        setReservations(reservations.map(r => 
          r.id === updatedReservation.id ? updatedReservation : r
        ));
      }
    });
  };

  const handleDelete = (id: any) => {
    Alert.alert(
      'Delete Reservation',
      'Are you sure you want to delete this reservation?',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Delete', 
          style: 'destructive',
          onPress: () => setReservations(reservations.filter(r => r.id !== id))
        }
      ]
    );
  };

  const handleExport = (format: any) => {
    setShowExportModal(false);
    Alert.alert('Export', `Exporting to ${format} format...`);
  };

  const calendarDays = getCurrentMonthDays();
  const selectedDateReservations = getReservationsForDate(selectedDate);

  return (
    <View style={styles.container}>
      {/* Header */}
      {/* Header */}
    <View style={styles.header}>
    <Text style={styles.headerTitle}>Room Reservations</Text>
    </View>

      <ScrollView style={styles.content}>
        {/* Action Buttons */}
        <View style={styles.actionButtons}>
          <TouchableOpacity style={styles.addButton} onPress={handleAdd}>
            <Text style={styles.buttonText}>+ Add Reservation</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={styles.exportButton} 
            onPress={() => setShowExportModal(true)}
          >
            <Text style={styles.buttonText}> Export</Text>
          </TouchableOpacity>
        </View>

        {/* Calendar View */}
        <View style={styles.calendarContainer}>
          <Text style={styles.monthTitle}>{getMonthName()}</Text>
          
          {/* Day Headers */}
          <View style={styles.weekDays}>
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <Text key={day} style={styles.weekDayText}>{day}</Text>
            ))}
          </View>

          {/* Calendar Grid */}
          <View style={styles.calendarGrid}>
            {calendarDays.map((dayInfo, index) => (
              <TouchableOpacity
                key={index}
                style={[
                  styles.calendarDay,
                  !dayInfo && styles.emptyDay,
                  dayInfo && dayInfo.date === selectedDate && styles.selectedDay,
                  dayInfo && dayInfo.hasReservation && styles.dayWithReservation,
                ]}
                onPress={() => dayInfo && setSelectedDate(dayInfo.date)}
                disabled={!dayInfo}
              >
                {dayInfo && (
                  <>
                    <Text style={[
                      styles.dayNumber,
                      dayInfo.date === selectedDate && styles.selectedDayText
                    ]}>
                      {dayInfo.day}
                    </Text>
                    {dayInfo.hasReservation && (
                      <View style={styles.reservationDot} />
                    )}
                  </>
                )}
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Reservations for Selected Date */}
        <View style={styles.reservationsSection}>
          <Text style={styles.sectionTitle}>
            Reservations for {selectedDate}
          </Text>
          
          {selectedDateReservations.length === 0 ? (
            <View style={styles.emptyState}>
              <Text style={styles.emptyText}>No reservations for this date</Text>
            </View>
          ) : (
            selectedDateReservations.map((reservation) => (
              <View key={reservation.id} style={styles.reservationCard}>
                <View style={styles.reservationInfo}>
                  <Text style={styles.reservationName}>{reservation.name}</Text>
                  <Text style={styles.reservationDetails}>
                    {reservation.room}
                  </Text>
                  <Text style={styles.reservationTime}>
                    {reservation.time} ({reservation.duration})
                  </Text>
                </View>
                
                <View style={styles.reservationActions}>
                  <TouchableOpacity 
                    style={styles.editButton}
                    onPress={() => handleEdit(reservation)}
                  >
                    <Text style={styles.editButtonText}>Edit</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity 
                    style={styles.deleteButton}
                    onPress={() => handleDelete(reservation.id)}
                  >
                    <Text style={styles.deleteButtonText}> Delete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))
          )}
        </View>

        {/* All Reservations */}
        <View style={styles.allReservationsSection}>
          <Text style={styles.sectionTitle}>All Reservations</Text>
          {reservations.map((reservation) => (
            <View key={reservation.id} style={styles.reservationCard}>
              <View style={styles.reservationInfo}>
                <Text style={styles.reservationName}>{reservation.name}</Text>
                <Text style={styles.reservationDetails}>
                  {reservation.room} • {reservation.date}
                </Text>
                <Text style={styles.reservationTime}>
                   {reservation.time} ({reservation.duration})
                </Text>
              </View>
              
              <View style={styles.reservationActions}>
                <TouchableOpacity 
                  style={styles.editButton}
                  onPress={() => handleEdit(reservation)}
                >
                  <Text style={styles.editButtonText}> Edit</Text>
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={styles.deleteButton}
                  onPress={() => handleDelete(reservation.id)}
                >
                  <Text style={styles.deleteButtonText}>Delete</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>

      {/* Export Modal */}
      <Modal
        visible={showExportModal}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setShowExportModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Export Format</Text>
            
            <TouchableOpacity 
              style={styles.modalButton}
              onPress={() => handleExport('PDF')}
            >
              <Text style={styles.modalButtonText}> PDF</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.modalButton}
              onPress={() => handleExport('Excel')}
            >
              <Text style={styles.modalButtonText}> Excel (XLSX)</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.modalButton}
              onPress={() => handleExport('CSV')}
            >
              <Text style={styles.modalButtonText}> CSV</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.modalButton, styles.cancelButton]}
              onPress={() => setShowExportModal(false)}
            >
              <Text style={styles.cancelButtonText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#6b8aa3',
    padding: 20,
    paddingTop: 20,
  },
  backButton: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 10,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
  },
  content: {
    flex: 1,
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 10,
    margin: 20,
    marginBottom: 10,
  },
  addButton: {
    flex: 1,
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  exportButton: {
    flex: 1,
    backgroundColor: '#2196F3',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  calendarContainer: {
    backgroundColor: '#fff',
    margin: 20,
    marginTop: 10,
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  monthTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
    color: '#333',
  },
  weekDays: {
    flexDirection: 'row',
    marginBottom: 10,
  },
  weekDayText: {
    flex: 1,
    textAlign: 'center',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#666',
  },
  calendarGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  calendarDay: {
    width: '14.28%',
    aspectRatio: 1,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#f0f0f0',
    position: 'relative',
  },
  emptyDay: {
    backgroundColor: '#fafafa',
  },
  selectedDay: {
    backgroundColor: '#6b8aa3',
    borderColor: '#6b8aa3',
  },
  dayWithReservation: {
    backgroundColor: '#e3f2fd',
  },
  dayNumber: {
    fontSize: 14,
    color: '#333',
  },
  selectedDayText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  reservationDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: '#4CAF50',
    position: 'absolute',
    bottom: 4,
  },
  reservationsSection: {
    padding: 20,
    paddingTop: 0,
  },
  allReservationsSection: {
    padding: 20,
    paddingTop: 0,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 15,
    color: '#333',
  },
  emptyState: {
    padding: 30,
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 10,
  },
  emptyText: {
    fontSize: 16,
    color: '#999',
  },
  reservationCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  reservationInfo: {
    marginBottom: 10,
  },
  reservationName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  reservationDetails: {
    fontSize: 14,
    color: '#666',
    marginBottom: 3,
  },
  reservationTime: {
    fontSize: 14,
    color: '#666',
  },
  reservationActions: {
    flexDirection: 'row',
    gap: 10,
  },
  editButton: {
    flex: 1,
    backgroundColor: '#FF9800',
    padding: 10,
    borderRadius: 6,
    alignItems: 'center',
  },
  editButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  deleteButton: {
    flex: 1,
    backgroundColor: '#f44336',
    padding: 10,
    borderRadius: 6,
    alignItems: 'center',
  },
  deleteButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    width: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  modalButton: {
    backgroundColor: '#2196F3',
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: 'center',
  },
  modalButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelButton: {
    backgroundColor: '#999',
    marginTop: 5,
  },
  cancelButtonText: {
    color: '#fff',
    fontSize: 16,
  },
});