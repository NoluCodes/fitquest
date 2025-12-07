// lib/data/repositories/workout_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../local/db_helper.dart';
import '../../models/workout.dart';
import '../../models/route_point.dart';

class WorkoutRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Insert a workout and its route points into local SQLite in a single transaction.
  Future<void> insertWorkoutLocal(Workout w) async {
    final db = await DBHelper.database;

    await db.transaction((txn) async {
      // Insert or replace workout row
      await txn.insert(
        'workouts',
        w.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert route points
      for (final p in w.points) {
        final map = p.toMap();
        if (map['id'] == null) map.remove('id');

        await txn.insert(
          'route_points',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Get saved workouts from local DB (most recent first)
  Future<List<Workout>> getWorkoutsLocal() async {
    final db = await DBHelper.database;
    final rows = await db.query('workouts', orderBy: 'startTime DESC');
    return rows.map((r) => Workout.fromMap(r)).toList();
  }

  /// Get route points for a workout ordered by seq (asc)
  Future<List<RoutePoint>> getPointsForWorkout(String workoutId) async {
    final db = await DBHelper.database;
    final rows = await db.query(
      'route_points',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'seq ASC',
    );
    return rows.map((r) => RoutePoint.fromMap(r)).toList();
  }

  /// Mark the workout as synced locally (optional, call after remote push)
  Future<void> markWorkoutSynced(String workoutId) async {
    final db = await DBHelper.database;
    await db.update('workouts', {'synced': 1}, where: 'id = ?', whereArgs: [workoutId]);
  }

  /// Sync workout and route points to Firestore
  Future<void> syncWorkoutToFirestore(Workout workout) async {
    try {
      final userRef = firestore.collection('users').doc(workout.userId);
      final workoutRef = userRef.collection('workouts').doc(workout.id);

      // Save workout metadata
      await workoutRef.set({
        'type': workout.type,
        'startTime': workout.startTime.toUtc(),
        'endTime': workout.endTime?.toUtc(),
        'distanceMeters': workout.distanceMeters,
        'version': workout.version,
      });

      // Save route points in batch
      final batch = firestore.batch();
      for (final point in workout.points) {
        final rpRef = workoutRef.collection('routePoints').doc(point.seq.toString());
        batch.set(rpRef, {
          'lat': point.lat,
          'lng': point.lng,
          'timestamp': point.timestamp.toUtc(),
          'seq': point.seq,
        });
      }
      await batch.commit();

      // Mark synced locally
      await markWorkoutSynced(workout.id);
    } catch (e) {
      print('Error syncing workout to Firestore: $e');
      // optionally handle retries or leave unsynced
    }
  }
}
