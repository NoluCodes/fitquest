import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/workout_view_model.dart';
import '../track/track_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthViewModel>().signOut(),
            tooltip: 'Sign out',
          )
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Welcome, ${user?.email ?? "athlete"}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.directions_run),
            label: const Text('Start Run'),
            onPressed: () {
              final uid = user?.uid ?? 'guest';
              Navigator.push(context, MaterialPageRoute(builder: (_) => TrackScreen(userId: uid)));
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.history),
            label: const Text('Workout History'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ]),
      ),
    );
  }
}
