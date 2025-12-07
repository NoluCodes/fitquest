import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/workout_view_model.dart';
import '../track/workout_detail_screen.dart'; // new screen we'll add

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WorkoutViewModel>().loadHistory());
  }

  Future<void> _refresh() async {
    await context.read<WorkoutViewModel>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: vm.history.isEmpty
            ? ListView( // ListView so RefreshIndicator can work even when empty
          children: const [
            SizedBox(height: 200),
            Center(child: Text('No workouts yet')),
          ],
        )
            : ListView.builder(
          itemCount: vm.history.length,
          itemBuilder: (context, i) {
            final w = vm.history[i];
            final dur = w.endTime != null ? w.endTime!.difference(w.startTime) : null;
            final dateText = _formatDate(w.startTime);
            return ListTile(
              title: Text('${w.type.toUpperCase()} • ${(w.distanceMeters / 1000).toStringAsFixed(2)} km'),
              subtitle: Text('$dateText • ${dur == null ? "—" : _durationToString(dur)}'),
              trailing: w.synced ? const Icon(Icons.cloud_done, color: Colors.green) : const Icon(Icons.cloud_upload),
              onTap: () {
                // Open workout details / replay
                Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w)));
              },
            );
          },
        ),
      ),
    );
  }

  static String _durationToString(Duration d) => '${d.inMinutes}m ${d.inSeconds % 60}s';

  static String _formatDate(DateTime dt) {
    // Simple human readable format: 2025-12-03 07:21
    final d = dt.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
