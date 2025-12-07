// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile_project_fitquest/data/repositories/workout_repository.dart';
// import 'package:mobile_project_fitquest/models/route_point.dart';
// import 'package:mobile_project_fitquest/models/workout.dart';
// import 'package:mobile_project_fitquest/screens/track/workout_detail_screen.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mocktail/mocktail.dart';
// // import 'package:your_app/models/workout.dart';
// // import 'package:your_app/models/route_point.dart';
// // import 'package:your_app/screens/workout_detail/workout_detail_screen.dart';
// // import 'package:your_app/data/repositories/workout_repository.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MockWorkoutRepository extends Mock implements WorkoutRepository {}
//
// void main() {
//   late MockWorkoutRepository mockRepo;
//   late Workout workout;
//
//   setUp(() {
//     mockRepo = MockWorkoutRepository();
//     workout = Workout(
//       id: 1,
//       type: 'Run',
//       distanceMeters: 5000,
//       startTime: DateTime(2025, 12, 6, 10, 0),
//       endTime: DateTime(2025, 12, 6, 10, 30),
//     );
//   });
//
//   testWidgets('shows "No points saved" when repo returns empty', (tester) async {
//     when(() => mockRepo.getPointsForWorkout(workout.id))
//         .thenAnswer(() async => []);
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: WorkoutDetailScreen(workout: workout, repo: mockRepo),
//       ),
//     );
//
//     await tester.pumpAndSettle();
//
//     expect(find.text('No points saved for this workout'), findsOneWidget);
//   });
//
//   testWidgets('shows GoogleMap when repo returns points', (tester) async {
//     when(() => mockRepo.getPointsForWorkout(workout.id))
//         .thenAnswer(() async => [RoutePoint(lat: 0, lng: 0)]);
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: WorkoutDetailScreen(workout: workout, repo: mockRepo),
//       ),
//     );
//
//     await tester.pumpAndSettle();
//
//     expect(find.byType(GoogleMap), findsOneWidget);
//   });
// }}