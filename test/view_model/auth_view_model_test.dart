// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile_project_fitquest/view_models/auth_view_model.dart';
// import 'package:mockito/mockito.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // ---------------- Mock classes ----------------
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}
// class MockUserCredential extends Mock implements UserCredential {}
// class MockUser extends Mock implements User {}
//
// // ---------------- Main test ----------------
// void main() {
//   late MockFirebaseAuth mockAuth;
//   late AuthViewModel authVM;
//
//   setUp(() {
//     mockAuth = MockFirebaseAuth();
//     authVM = AuthViewModel(auth: mockAuth); // inject mock
//   });
//
//   group('AuthViewModel tests', () {
//     test('signIn sets user on success', () async {
//       final mockUser = MockUser();
//       final mockCred = MockUserCredential();
//
//       // Mock UserCredential.user
//       when(mockCred.user).thenReturn(mockUser);
//
//       // Mock FirebaseAuth.signInWithEmailAndPassword
//       when(mockAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenAnswer((_) async => mockCred);
//
//       // Call signIn
//       final success = await authVM.signIn('test@test.com', '123456');
//
//       expect(success, true);
//       // AuthViewModel.user is updated via authStateChanges listener
//       // Simulate auth state change
//       when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
//       await Future.delayed(const Duration(milliseconds: 10));
//       expect(authVM.user, mockUser);
//       expect(authVM.isLoading, false);
//       expect(authVM.errorMessage, null);
//     });
//
//     test('signIn sets errorMessage on failure', () async {
//       // Mock FirebaseAuth exception
//       when(mockAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenThrow(FirebaseAuthException(code: 'wrong-password', message: 'Wrong password'));
//
//       final success = await authVM.signIn('test@test.com', 'wrongpassword');
//
//       expect(success, false);
//       expect(authVM.errorMessage, 'Wrong password');
//       expect(authVM.isLoading, false);
//     });
//
//     test('signUp sets user on success', () async {
//       final mockUser = MockUser();
//       final mockCred = MockUserCredential();
//
//       when(mockCred.user).thenReturn(mockUser);
//
//       when(mockAuth.createUserWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenAnswer((_) async => mockCred);
//
//       when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
//       when(mockUser.reload()).thenAnswer((_) async {});
//
//       // Simulate currentUser after reload
//       when(mockAuth.currentUser).thenReturn(mockUser);
//
//       final success = await authVM.signUp(
//         email: 'new@test.com',
//         password: '123456',
//         displayName: 'Tester',
//       );
//
//       expect(success, true);
//       expect(authVM.user, mockUser);
//       expect(authVM.errorMessage, null);
//       expect(authVM.isLoading, false);
//     });
//
//     test('signUp sets errorMessage on failure', () async {
//       when(mockAuth.createUserWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenThrow(FirebaseAuthException(code: 'email-already-in-use', message: 'Email exists'));
//
//       final success = await authVM.signUp(
//         email: 'existing@test.com',
//         password: '123456',
//         displayName: 'Tester',
//       );
//
//       expect(success, false);
//       expect(authVM.errorMessage, 'Email exists');
//       expect(authVM.isLoading, false);
//     });
//
//     test('signOut clears user', () async {
//       authVM.user = MockUser();
//       await authVM.signOut();
//
//       verify(mockAuth.signOut()).called(1);
//       expect(authVM.user, null);
//     });
//   });
// }