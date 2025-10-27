import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TextInput, TouchableOpacity, Alert } from 'react-native';

export default function AddEditReservationScreen({ route, navigation }: { route: any, navigation: any}) {
  const { mode, reservation, onSave } = route.params;
  const isEdit = mode === 'edit';
  
  const [name, setName] = useState(reservation?.name || '');
  const [room, setRoom] = useState(reservation?.room || '');
  const [date, setDate] = useState(reservation?.date || '');
  const [time, setTime] = useState(reservation?.time || '');
  const [duration, setDuration] = useState(reservation?.duration || '');
  const [showRecommendations, setShowRecommendations] = useState(false);

  // Sample available rooms
  const rooms = ['Room A', 'Room B', 'Room C', 'Room D', 'Meeting Room 1', 'Conference Room'];

  // Validation
  const validateForm = () => {
    if (!name.trim()) {
      Alert.alert('Validation Error', 'Please enter a name');
      return false;
    }
    if (!room.trim()) {
      Alert.alert('Validation Error', 'Please select a room');
      return false;
    }
    if (!date.trim()) {
      Alert.alert('Validation Error', 'Please enter a date (YYYY-MM-DD)');
      return false;
    }
    if (!time.trim()) {
      Alert.alert('Validation Error', 'Please enter time (HH:MM-HH:MM)');
      return false;
    }
    if (!duration.trim()) {
      Alert.alert('Validation Error', 'Please enter duration');
      return false;
    }
    
    // Basic date format validation
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(date)) {
      Alert.alert('Validation Error', 'Date must be in format YYYY-MM-DD (e.g., 2025-10-28)');
      return false;
    }

    return true;
  };

  const handleSave = () => {
    if (!validateForm()) return;

    const reservationData = {
      ...(isEdit && { id: reservation.id }),
      name: name.trim(),
      room: room.trim(),
      date: date.trim(),
      time: time.trim(),
      duration: duration.trim(),
    };

    onSave(reservationData);
    Alert.alert(
      'Success',
      `Reservation ${isEdit ? 'updated' : 'created'} successfully!`,
      [{ text: 'OK', onPress: () => navigation.goBack() }]
    );
  };

  // Get recommendations based on current input
  const getRecommendations = () => {
    // This is a simple example. In a real app, you'd check against existing reservations
    const recommendations = [
      { time: '09:00-10:00', room: 'Room A', availability: 'Available' },
      { time: '10:00-11:00', room: 'Room B', availability: 'Available' },
      { time: '14:00-15:00', room: 'Room C', availability: 'Available' },
      { time: '15:00-16:00', room: 'Conference Room', availability: 'Available' },
    ];
    return recommendations;
  };

  const applyRecommendation = (recommendation: any) => {
    setRoom(recommendation.room);
    setTime(recommendation.time);
    setShowRecommendations(false);
    Alert.alert('Applied', 'Recommendation has been applied to the form');
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backButton}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>
          {isEdit ? 'Edit Reservation' : 'Add Reservation'}
        </Text>
      </View>

      <ScrollView style={styles.content}>
        {/* Form */}
        <View style={styles.form}>
          <Text style={styles.label}>Name *</Text>
          <TextInput
            style={styles.input}
            value={name}
            onChangeText={setName}
            placeholder="Enter your name"
            placeholderTextColor="#999"
          />

          <Text style={styles.label}>Room *</Text>
          <View style={styles.roomContainer}>
            <TextInput
              style={[styles.input, { flex: 1 }]}
              value={room}
              onChangeText={setRoom}
              placeholder="Select or type room name"
              placeholderTextColor="#999"
            />
          </View>
          <View style={styles.roomChips}>
            {rooms.map((r) => (
              <TouchableOpacity
                key={r}
                style={[styles.chip, room === r && styles.chipSelected]}
                onPress={() => setRoom(r)}
              >
                <Text style={[styles.chipText, room === r && styles.chipTextSelected]}>
                  {r}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <Text style={styles.label}>Date * (YYYY-MM-DD)</Text>
          <TextInput
            style={styles.input}
            value={date}
            onChangeText={setDate}
            placeholder="2025-10-28"
            placeholderTextColor="#999"
          />

          <Text style={styles.label}>Time * (HH:MM-HH:MM)</Text>
          <TextInput
            style={styles.input}
            value={time}
            onChangeText={setTime}
            placeholder="09:00-10:00"
            placeholderTextColor="#999"
          />

          <Text style={styles.label}>Duration *</Text>
          <TextInput
            style={styles.input}
            value={duration}
            onChangeText={setDuration}
            placeholder="1 hour"
            placeholderTextColor="#999"
          />

          {/* Recommendation Button */}
          <TouchableOpacity
            style={styles.recommendButton}
            onPress={() => setShowRecommendations(!showRecommendations)}
          >
            <Text style={styles.recommendButtonText}>
               {showRecommendations ? 'Hide' : 'Show'} Recommendations
            </Text>
          </TouchableOpacity>

          {/* Recommendations */}
          {showRecommendations && (
            <View style={styles.recommendationsContainer}>
              <Text style={styles.recommendationsTitle}>
                Available Time Slots:
              </Text>
              {getRecommendations().map((rec, index) => (
                <TouchableOpacity
                  key={index}
                  style={styles.recommendationCard}
                  onPress={() => applyRecommendation(rec)}
                >
                  <Text style={styles.recommendationTime}>{rec.time}</Text>
                  <Text style={styles.recommendationRoom}>{rec.room}</Text>
                  <Text style={styles.recommendationStatus}>{rec.availability}</Text>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {/* Save Button */}
          <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
            <Text style={styles.saveButtonText}>
              {isEdit ? ' Update Reservation' : 'Create Reservation'}
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
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
    paddingTop: 50,
  },
  backButton: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 10,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  content: {
    flex: 1,
  },
  form: {
    padding: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
    marginTop: 15,
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#333',
  },
  roomContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  roomChips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 10,
  },
  chip: {
    backgroundColor: '#e0e0e0',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  chipSelected: {
    backgroundColor: '#6b8aa3',
  },
  chipText: {
    fontSize: 14,
    color: '#333',
  },
  chipTextSelected: {
    color: '#fff',
    fontWeight: '600',
  },
  recommendButton: {
    backgroundColor: '#9C27B0',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  recommendButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  recommendationsContainer: {
    marginTop: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  recommendationsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  recommendationCard: {
    backgroundColor: '#f5f5f5',
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  recommendationTime: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  recommendationRoom: {
    fontSize: 14,
    color: '#666',
    marginBottom: 3,
  },
  recommendationStatus: {
    fontSize: 12,
    color: '#4CAF50',
    fontWeight: '600',
  },
  saveButton: {
    backgroundColor: '#4CAF50',
    padding: 18,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 30,
    marginBottom: 30,
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});