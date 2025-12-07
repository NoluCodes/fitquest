// lib/screens/track_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../view_models/workout_view_model.dart';
import '../../models/route_point.dart';

class TrackScreen extends StatefulWidget {
  final String userId;
  const TrackScreen({super.key, required this.userId});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  GoogleMapController? _mapController;

  // for user drawing
  final List<LatLng> _userRoutePoints = [];

  // polyline for route and runner
  final Set<Polyline> _polylines = {};
  Marker? _runnerMarker;

  bool _simulating = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updatePolyline();
  }

  void _updatePolyline() {
    _polylines.clear();
    if (_userRoutePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('user_route'),
          points: _userRoutePoints,
          color: Colors.indigo,
          width: 5,
        ),
      );
    }
    setState(() {});
  }

  void _addPoint(LatLng point) {
    setState(() {
      _userRoutePoints.add(point);
      _updatePolyline();
    });
  }

  Future<void> _simulateWorkout() async {
    if (_userRoutePoints.isEmpty) return;

    final vm = context.read<WorkoutViewModel>();
    await vm.startWorkout(widget.userId);

    _simulating = true;

    int seq = 0;
    for (var latLng in _userRoutePoints) {
      if (!_simulating) break;

      final rp = RoutePoint(
        workoutId: vm.currentWorkout!.id,
        lat: latLng.latitude,
        lng: latLng.longitude,
        seq: seq++,
      );

      // add point to current workout
      vm.currentWorkout!.points.add(rp);

      // update distance
      if (vm.currentWorkout!.points.length > 1) {
        final prev = vm.currentWorkout!.points[vm.currentWorkout!.points.length - 2];
        final dist = _distance(prev, rp);
        vm.currentWorkout!.distanceMeters += dist;
      }

      // move runner marker
      _runnerMarker = Marker(
        markerId: const MarkerId('runner'),
        position: latLng,
      );

      // animate map
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

      vm.notifyListeners();

      await Future.delayed(const Duration(seconds: 5)); // 1x speed = 5s per segment
    }

    await vm.stopWorkout();
    _simulating = false;
  }

  double _distance(RoutePoint a, RoutePoint b) {
    return Geolocator.distanceBetween(a.lat, a.lng, b.lat, b.lng);
  }

  void _stopSimulation() {
    _simulating = false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Track Run')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
              const CameraPosition(target: LatLng(-33.9249, 18.4241), zoom: 14),
              polylines: _polylines,
              markers: _runnerMarker != null ? {_runnerMarker!} : {},
              onTap: _addPoint,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text('Distance: ${vm.getDistanceKm()} km', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Simulate'),
                      onPressed: _simulating ? null : _simulateWorkout,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      onPressed: _simulating ? _stopSimulation : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      onPressed: _simulating
                          ? null
                          : () {
                        setState(() {
                          _userRoutePoints.clear();
                          _runnerMarker = null;
                          _updatePolyline();
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Tap map to add route points.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
