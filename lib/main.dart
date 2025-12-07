import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/workout_view_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FitQuestApp());
}

class FitQuestApp extends StatelessWidget {
  const FitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "FitQuest",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),

        /// Show correct screen depending on logged-in state
        home: Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return auth.user != null
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}


