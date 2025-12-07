import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/workout.dart';
import '../../models/route_point.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutRepository _repo = WorkoutRepository();
  List<RoutePoint> _points = [];
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  LatLng? _initialCamera;
  Timer? _replayTimer;
  int _replayIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  @override
  void dispose() {
    _replayTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    final pts = await _repo.getPointsForWorkout(widget.workout.id);
    setState(() {
      _points = pts;
      if (_points.isNotEmpty) {
        _initialCamera = LatLng(_points.first.lat, _points.first.lng);
        _polylines.clear();
        _polylines.add(Polyline(polylineId: const PolylineId('route'), points: _points.map((p) => LatLng(p.lat, p.lng)).toList(), width: 5, color: Colors.indigo));
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_initialCamera != null) {
      _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_initialCamera!, 16));
    }
  }

  void _toggleReplay() {
    if (_isPlaying) {
      _replayTimer?.cancel();
      setState(() => _isPlaying = false);
      return;
    }

    if (_points.isEmpty) return;
    setState(() {
      _isPlaying = true;
      _replayIndex = 0;
    });

    _replayTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (_replayIndex >= _points.length) {
        t.cancel();
        setState(() => _isPlaying = false);
        return;
      }
      final rp = _points[_replayIndex];
      final latLng = LatLng(rp.lat, rp.lng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      _replayIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.workout.endTime != null ? widget.workout.endTime!.difference(widget.workout.startTime) : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: Column(
        children: [
          Expanded(
            child: _initialCamera == null
                ? const Center(child: Text('No points saved for this workout'))
                : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _initialCamera!, zoom: 16),
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Text('Type: ${widget.workout.type}'),
              const SizedBox(height: 4),
              Text('Distance: ${(widget.workout.distanceMeters / 1000).toStringAsFixed(2)} km'),
              const SizedBox(height: 4),
              Text('Duration: ${duration == null ? "—" : "${duration.inMinutes}m ${duration.inSeconds % 60}s"}'),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton.icon(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Pause' : 'Replay'),
                  onPressed: _toggleReplay,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.zoom_out_map),
                  label: const Text('Fit Route'),
                  onPressed: _fitRoute,
                ),
              ])
            ]),
          )
        ],
      ),
    );
  }

  Future<void> _fitRoute() async {
    if (_points.isEmpty || _mapController == null) return;
    final lats = _points.map((e) => e.lat).toList();
    final lngs = _points.map((e) => e.lng).toList();
    final north = lats.reduce((a, b) => a > b ? a : b);
    final south = lats.reduce((a, b) => a < b ? a : b);
    final east = lngs.reduce((a, b) => a > b ? a : b);
    final west = lngs.reduce((a, b) => a < b ? a : b);

    final padding = 0.01;
    final ne = LatLng(north + padding, east + padding);
    final sw = LatLng(south - padding, west - padding);
    final bounds = LatLngBounds(southwest: sw, northeast: ne);

    await _mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
