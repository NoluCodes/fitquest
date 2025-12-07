import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/local/db_helper.dart';
import '../data/repositories/workout_repository.dart';
import '../models/workout.dart';
import '../models/route_point.dart';
import '../data/repositories/firestore_repository.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _repo = WorkoutRepository();
  final _fsRepo = FirestoreRepository();

  bool tracking = false;
  Workout? currentWorkout;
  StreamSubscription<Position>? _positionSub;
  int _seq = 0;
  List<Workout> history = [];

  /// Start a workout
  Future<void> startWorkout(String userId, {String type = 'run'}) async {
    currentWorkout = Workout(userId: userId, type: type);
    tracking = true;
    _seq = 0;

    // location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      tracking = false;
      notifyListeners();
      return;
    }

    // subscribe to location updates
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((pos) async {
      if (currentWorkout == null) return;

      final rp = RoutePoint(
        workoutId: currentWorkout!.id,
        lat: pos.latitude,
        lng: pos.longitude,
        seq: _seq++,
      );

      currentWorkout!.points.add(rp);

      try {
        await DBHelper.insertRoutePoint(rp.toMap());
      } catch (_) {}

      if (currentWorkout!.points.length > 1) {
        final prev = currentWorkout!.points[currentWorkout!.points.length - 2];
        final dist = Geolocator.distanceBetween(prev.lat, prev.lng, rp.lat, rp.lng);
        currentWorkout!.distanceMeters += dist;
      }

      notifyListeners();
    });

    notifyListeners();
  }

  /// Stop workout
  Future<void> stopWorkout({bool save = true}) async {
    if (!tracking || currentWorkout == null) return;

    tracking = false;
    currentWorkout!.endTime = DateTime.now();

    await _positionSub?.cancel();
    _positionSub = null;

    if (save) {
      currentWorkout!.version += 1;
      currentWorkout!.synced = false;

      // save locally
      try {
        await _repo.insertWorkoutLocal(currentWorkout!);
      } catch (_) {}

      // attempt Firestore sync
      try {
        await _fsRepo.saveWorkout(currentWorkout!);
        currentWorkout!.synced = true;
        await _repo.markWorkoutSynced(currentWorkout!.id);
      } catch (e) {
        print('Error syncing to Firestore: $e');
      }
    }

    currentWorkout = null;
    await loadHistory();
    notifyListeners();
  }

  /// Load workout history
  Future<void> loadHistory() async {
    try {
      history = await _repo.getWorkoutsLocal();
    } catch (_) {
      history = [];
    }
    notifyListeners();
  }

  /// Get distance in km
  String getDistanceKm() {
    if (currentWorkout == null) return '0.00';
    return (currentWorkout!.distanceMeters / 1000).toStringAsFixed(2);
  }

  /// Sync all unsynced workouts to Firestore
  Future<void> syncUnsyncedWorkouts() async {
    final unsynced = history.where((w) => !w.synced).toList();

    for (final w in unsynced) {
      try {
        await _fsRepo.saveWorkout(w);
        w.synced = true;
        await _repo.markWorkoutSynced(w.id);
      } catch (e) {
        print('Failed to sync workout ${w.id}: $e');
      }
    }

    await loadHistory();
  }
}
