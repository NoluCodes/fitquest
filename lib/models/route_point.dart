class RoutePoint {
  int? id;
  final String workoutId;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final int seq;

  RoutePoint({this.id, required this.workoutId, required this.lat, required this.lng, DateTime? timestamp, required this.seq})
      : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'workoutId': workoutId,
    'lat': lat,
    'lng': lng,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'seq': seq,
  };

  factory RoutePoint.fromMap(Map<String, dynamic> m) => RoutePoint(
    id: m['id'] as int?,
    workoutId: m['workoutId'],
    lat: (m['lat'] as num).toDouble(),
    lng: (m['lng'] as num).toDouble(),
    timestamp: DateTime.parse(m['timestamp']).toLocal(),
    seq: m['seq'] as int,
  );
}
