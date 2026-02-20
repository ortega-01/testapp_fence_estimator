import 'package:flutter/material.dart';
import '../models/fence_models.dart';
import '../theme/app_theme.dart';

class EstimationResultPage extends StatelessWidget {
  final EstimationResult result;
  const EstimationResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Estimation Results')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 40 : 16,
            vertical: 24,
          ),
          child: isWide ? _wideLayout(context) : _narrowLayout(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showShareSheet(context),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────── Layouts ──────

  Widget _wideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _materialsSection(context)),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: _laborSection(context)),
      ],
    );
  }

  Widget _narrowLayout(BuildContext context) {
    return Column(
      children: [
        _summaryHeader(context),
        const SizedBox(height: 16),
        _materialsSection(context),
        const SizedBox(height: 24),
        _laborSection(context),
      ],
    );
  }

  // ────── Summary header ──────

  Widget _summaryHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(AppTheme.iconForFenceType(result.fenceType),
                size: 36, color: cs.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.fenceType.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${result.linearFeet.toStringAsFixed(0)} linear ft',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────── Materials ──────

  Widget _materialsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summaryHeader(context),
        const SizedBox(height: 16),
        Text(
          'Materials',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(cs.primaryContainer.withOpacity(0.4)),
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Item')),
              DataColumn(label: Text('Qty'), numeric: true),
              DataColumn(label: Text('Unit')),
            ],
            rows: result.materials.map((m) {
              return DataRow(cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.name, style: const TextStyle(fontSize: 14)),
                      if (m.note != null)
                        Text(m.note!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                DataCell(Text('${m.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15))),
                DataCell(Text(m.unit)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ────── Labor ──────

  Widget _laborSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labor = result.labor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Labor Estimate',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _laborTile(
                  context,
                  icon: Icons.schedule,
                  label: 'Estimated Hours',
                  value: labor.formattedRange,
                ),
                const Divider(height: 24),
                _laborTile(
                  context,
                  icon: Icons.group,
                  label: 'Crew Size',
                  value: '${labor.crewSize} workers',
                ),
                const Divider(height: 24),
                _laborTile(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Est. Calendar Days',
                  value:
                      '${(labor.hoursHigh / 8).ceil()} day(s) @ 8 hrs/day',
                ),
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labor.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _laborTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // ────── Share / copy to clipboard ──────

  void _showShareSheet(BuildContext context) {
    final buf = StringBuffer();
    buf.writeln('=== Fence Estimation Report ===');
    buf.writeln(
        '${result.fenceType.label} — ${result.linearFeet.toStringAsFixed(0)} linear ft\n');
    buf.writeln('--- Materials ---');
    for (final m in result.materials) {
      buf.writeln('  ${m.name}: ${m.quantity} ${m.unit}');
    }
    buf.writeln('\n--- Labor ---');
    buf.writeln('  Hours: ${result.labor.formattedRange}');
    buf.writeln('  Crew: ${result.labor.crewSize}');
    buf.writeln('  ${result.labor.summary}');

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: SelectableText(
            buf.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ),
      ),
    );
  }
}
