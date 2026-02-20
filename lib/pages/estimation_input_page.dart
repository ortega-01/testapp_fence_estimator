import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fence_models.dart';
import '../services/fence_estimator.dart';
import '../theme/app_theme.dart';
import 'estimation_result_page.dart';

class EstimationInputPage extends StatefulWidget {
  const EstimationInputPage({super.key});

  @override
  State<EstimationInputPage> createState() => _EstimationInputPageState();
}

class _EstimationInputPageState extends State<EstimationInputPage> {
  late FenceJobInput _job;
  final _linearFeetController = TextEditingController();
  final _cornersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _job = FenceJobInput();
    _linearFeetController.text = _job.totalLinearFeet.toStringAsFixed(0);
    _cornersController.text = _job.corners.toString();
  }

  @override
  void dispose() {
    _linearFeetController.dispose();
    _cornersController.dispose();
    super.dispose();
  }

  // ────────── build ──────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fence Estimator'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 24,
          ),
          child: isWide ? _wideLayout() : _narrowLayout(),
        ),
      ),
      bottomNavigationBar: _estimateButton(),
    );
  }

  // ────── Tablet / wide layout (two columns) ──────

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _leftColumn()),
        const SizedBox(width: 32),
        Expanded(child: _rightColumn()),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      children: [
        _leftColumn(),
        const SizedBox(height: 16),
        _rightColumn(),
      ],
    );
  }

  // ────── left column: fence type + dimensions ──────

  Widget _leftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('Fence Type'),
        const SizedBox(height: 8),
        _fenceTypeSelector(),
        const SizedBox(height: 24),
        _sectionHeader('Dimensions'),
        const SizedBox(height: 8),
        _dimensionsCard(),
      ],
    );
  }

  // ────── right column: slope, gates ──────

  Widget _rightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('Terrain'),
        const SizedBox(height: 8),
        _slopeSelector(),
        const SizedBox(height: 24),
        _sectionHeader('Gates'),
        const SizedBox(height: 8),
        _gatesCard(),
      ],
    );
  }

  // ═══════════════════  WIDGETS  ═══════════════════

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  // ── Fence type ──

  Widget _fenceTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: FenceType.values.map((type) {
            final selected = type == _job.fenceType;
            return ChoiceChip(
              avatar: Icon(
                AppTheme.iconForFenceType(type),
                size: 20,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
              label: Text(type.label),
              selected: selected,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
              showCheckmark: false,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (_) => _selectFenceType(type),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Dimensions card ──

  Widget _dimensionsCard() {
    final heights = FenceHeight.forType(_job.fenceType);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Height
            Row(
              children: [
                const Icon(Icons.height, size: 20),
                const SizedBox(width: 8),
                const Text('Height:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<double>(
                    segments: heights
                        .map((h) => ButtonSegment(
                              value: h.feet,
                              label: Text(h.label),
                            ))
                        .toList(),
                    selected: {_job.height.feet},
                    onSelectionChanged: (sel) {
                      setState(() {
                        _job.height = heights.firstWhere(
                            (h) => h.feet == sel.first);
                      });
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.comfortable,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Linear feet
            Row(
              children: [
                const Icon(Icons.straighten, size: 20),
                const SizedBox(width: 8),
                const Text('Linear feet:',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _linearFeetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null && n > 0) {
                        _job.totalLinearFeet = n;
                      }
                    },
                    decoration: const InputDecoration(
                      suffixText: 'ft',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Corners / ends
            Row(
              children: [
                const Icon(Icons.turn_right, size: 20),
                const SizedBox(width: 8),
                const Text('Corners / ends:',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _cornersController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 0) {
                        _job.corners = n;
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Slope selector ──

  Widget _slopeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: SlopeGrade.values.map((grade) {
            return RadioListTile<SlopeGrade>(
              title: Text(grade.label, style: const TextStyle(fontSize: 16)),
              value: grade,
              groupValue: _job.slope,
              dense: true,
              onChanged: (v) => setState(() => _job.slope = v!),
              secondary: Icon(
                grade == SlopeGrade.none
                    ? Icons.horizontal_rule
                    : Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Gates card ──

  Widget _gatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_job.gates.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No gates added yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            ..._job.gates.asMap().entries.map((entry) {
              final i = entry.key;
              final gate = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<GateSize>(
                        value: gate.size,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: GateSize.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label,
                                      style: const TextStyle(fontSize: 15)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => gate.size = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Qty:', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      child: DropdownButton<int>(
                        value: gate.quantity,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: List.generate(
                          5,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}',
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        onChanged: (v) =>
                            setState(() => gate.quantity = v!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      tooltip: 'Remove gate',
                      onPressed: () =>
                          setState(() => _job.gates.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _job.gates.add(GateEntry())),
                icon: const Icon(Icons.add),
                label: const Text('Add Gate',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom estimate button ──

  Widget _estimateButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: FilledButton.icon(
          onPressed: _runEstimate,
          icon: const Icon(Icons.calculate, size: 24),
          label: const Text('Estimate'),
        ),
      ),
    );
  }

  // ═══════════════════  ACTIONS  ═══════════════════

  void _selectFenceType(FenceType type) {
    setState(() {
      _job.fenceType = type;
      // Reset height to first available for new type.
      _job.height = FenceHeight.forType(type).first;
    });
  }

  void _reset() {
    setState(() {
      _job = FenceJobInput();
      _linearFeetController.text =
          _job.totalLinearFeet.toStringAsFixed(0);
      _cornersController.text = _job.corners.toString();
    });
  }

  void _runEstimate() {
    // Quick validation
    final ft = double.tryParse(_linearFeetController.text);
    if (ft == null || ft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid linear footage.')),
      );
      return;
    }
    _job.totalLinearFeet = ft;
    _job.corners = int.tryParse(_cornersController.text) ?? 2;

    final result = FenceEstimator.estimate(_job);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstimationResultPage(result: result),
      ),
    );
  }
}
