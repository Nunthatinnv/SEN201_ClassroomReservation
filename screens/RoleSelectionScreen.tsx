// import React from 'react';
// import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

// export default function RoleSelectionScreen({ navigation }) {
//   const handleRoleSelection = (role) => {
//     navigation.navigate('Dashboard', { role });
//   };

//   return (
//     <View style={styles.container}>
//       <Text style={styles.title}>Room Reservation System</Text>
      
//       <View style={styles.contentContainer}>
//         <Text style={styles.brandName}>Schedool</Text>
        
//         <View style={styles.questionContainer}>
//           <Text style={styles.question}>Who are you?</Text>
          
          
            
//           </View>
//         </View>
//       </View>
//   );
// }

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: '#f5f5f5',
//   },
//   title: {
//     fontSize: 28,
//     fontWeight: '400',
//     padding: 20,
//     paddingTop: 60,
//     backgroundColor: '#e0e0e0',
//   },
//   contentContainer: {
//     flex: 1,
//     backgroundColor: '#fff',
//     margin: 20,
//     marginTop: 40,
//     borderRadius: 10,
//     padding: 40,
//     shadowColor: '#000',
//     shadowOffset: { width: 0, height: 2 },
//     shadowOpacity: 0.1,
//     shadowRadius: 8,
//     elevation: 5,
//   },
//   brandName: {
//     fontSize: 60,
//     fontWeight: '600',
//     textAlign: 'center',
//     marginBottom: 80,
//     marginTop: 40,
//   },
//   questionContainer: {
//     alignItems: 'center',
//   },
//   question: {
//     fontSize: 24,
//     marginBottom: 20,
//   },
//   buttonContainer: {
//     flexDirection: 'row',
//     gap: 15,
//   },
//   button: {
//     paddingHorizontal: 40,
//     paddingVertical: 15,
//     borderRadius: 8,
//     minWidth: 130,
//     alignItems: 'center',
//   },
//   teacherButton: {
//     backgroundColor: '#a3b8cc',
//   },
//   adminButton: {
//     backgroundColor: '#d0d0d0',
//   },
//   buttonText: {
//     fontSize: 20,
//     color: '#000',
//   },
// });