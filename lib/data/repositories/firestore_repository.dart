import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/workout.dart';
import '../../models/route_point.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveWorkout(Workout workout) async {
    final workoutRef = _firestore.collection('workouts').doc(workout.id);

    await workoutRef.set({
      'id': workout.id,
      'userId': workout.userId,
      'type': workout.type,
      'startTime': workout.startTime.toIso8601String(),
      'endTime': workout.endTime?.toIso8601String(),
      'distanceMeters': workout.distanceMeters,
      'version': workout.version,
      'synced': workout.synced,
    });

    // Save all route points
    for (var point in workout.points) {
      await workoutRef.collection('route_points').doc(point.seq.toString()).set({
        'lat': point.lat,
        'lng': point.lng,
        'timestamp': point.timestamp.toIso8601String(),
        'seq': point.seq,
      });
    }
  }

  Future<List<Workout>> getWorkouts(String userId) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();

    List<Workout> workouts = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final pointsSnapshot = await doc.reference.collection('route_points').orderBy('seq').get();
      List<RoutePoint> points = pointsSnapshot.docs.map((p) => RoutePoint(
        workoutId: data['id'],
        lat: p['lat'],
        lng: p['lng'],
        timestamp: DateTime.parse(p['timestamp']),
        seq: p['seq'],
      )).toList();

      workouts.add(Workout(
        id: data['id'],
        userId: data['userId'],
        type: data['type'],
        startTime: DateTime.parse(data['startTime']),
        endTime: data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
        distanceMeters: data['distanceMeters'],
        version: data['version'],
        synced: data['synced'],
        points: points,
      ));
    }
    return workouts;
  }
}
