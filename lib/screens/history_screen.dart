import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/history_repository.dart';
import '../models/history_entry.dart';

class _HistoryView extends ConsumerStatefulWidget {
  const _HistoryView({super.key});

  @override
  ConsumerState<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<_HistoryView> {
  List<HistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await HistoryRepository.instance.getAll();
    setState(() {
      _entries = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (c, i) {
        final e = _entries[i];
        return ListTile(title: Text('Med ${e.medicineId}'), subtitle: Text('${e.status} • ${e.time.toLocal()}'));
      },
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('History & Analytics')), body: const _HistoryView());
  }
}
