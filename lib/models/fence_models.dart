/// All the fence types supported by the estimator.
enum FenceType {
  chainLink('Chain Link', 'Galvanized steel mesh fencing'),
  wood('Wood', 'Pressure-treated wood privacy fence'),
  vinyl('Vinyl', 'PVC vinyl privacy fence'),
  aluminum('Aluminum', 'Ornamental aluminum fence'),
  wroughtIron('Wrought Iron', 'Decorative wrought-iron fence'),
  compositeMixed('Composite', 'Wood-plastic composite fence');

  const FenceType(this.label, this.description);
  final String label;
  final String description;
}

/// Heights commonly available per fence type.
class FenceHeight {
  const FenceHeight(this.feet, this.label);
  final double feet;
  final String label;

  static List<FenceHeight> forType(FenceType type) {
    switch (type) {
      case FenceType.chainLink:
        return const [
          FenceHeight(4, '4 ft'),
          FenceHeight(5, '5 ft'),
          FenceHeight(6, '6 ft'),
          FenceHeight(8, '8 ft'),
        ];
      case FenceType.wood:
      case FenceType.vinyl:
      case FenceType.compositeMixed:
        return const [
          FenceHeight(4, '4 ft'),
          FenceHeight(6, '6 ft'),
          FenceHeight(8, '8 ft'),
        ];
      case FenceType.aluminum:
      case FenceType.wroughtIron:
        return const [
          FenceHeight(3, '3 ft'),
          FenceHeight(4, '4 ft'),
          FenceHeight(5, '5 ft'),
          FenceHeight(6, '6 ft'),
        ];
    }
  }
}

/// Gate size options.
enum GateSize {
  standard('Standard Walk Gate', 3.5),
  doubleGate('Double Gate', 6.0),
  sliding('Sliding Gate', 10.0);

  const GateSize(this.label, this.widthFeet);
  final String label;
  final double widthFeet;
}

/// Slope grade categories.
enum SlopeGrade {
  none('None (Flat)', 0),
  mild('Mild (5-10°)', 7.5),
  moderate('Moderate (10-20°)', 15),
  steep('Steep (20-30°)', 25);

  const SlopeGrade(this.label, this.degrees);
  final String label;
  final double degrees;
}

/// User input for a fence estimation job.
class FenceJobInput {
  FenceType fenceType;
  FenceHeight height;
  double totalLinearFeet;
  SlopeGrade slope;
  List<GateEntry> gates;
  int corners; // number of corner / end posts

  FenceJobInput({
    this.fenceType = FenceType.chainLink,
    FenceHeight? height,
    this.totalLinearFeet = 100,
    this.slope = SlopeGrade.none,
    List<GateEntry>? gates,
    this.corners = 2,
  })  : height = height ?? FenceHeight.forType(FenceType.chainLink).first,
        gates = gates ?? [];
}

/// A single gate entry.
class GateEntry {
  GateSize size;
  int quantity;
  GateEntry({this.size = GateSize.standard, this.quantity = 1});
}

/// ───────────── ESTIMATION RESULT ─────────────

class EstimationResult {
  final FenceType fenceType;
  final double linearFeet;
  final List<MaterialLineItem> materials;
  final LaborEstimate labor;

  const EstimationResult({
    required this.fenceType,
    required this.linearFeet,
    required this.materials,
    required this.labor,
  });
}

class MaterialLineItem {
  final String name;
  final int quantity;
  final String unit;
  final String? note;

  const MaterialLineItem({
    required this.name,
    required this.quantity,
    this.unit = 'pcs',
    this.note,
  });
}

class LaborEstimate {
  final double hoursLow;
  final double hoursHigh;
  final int crewSize;
  final String summary;

  const LaborEstimate({
    required this.hoursLow,
    required this.hoursHigh,
    required this.crewSize,
    required this.summary,
  });

  String get formattedRange {
    String _fmt(double h) {
      final hrs = h.floor();
      final mins = ((h - hrs) * 60).round();
      if (mins == 0) return '${hrs}h';
      return '${hrs}h ${mins}m';
    }

    return '${_fmt(hoursLow)} – ${_fmt(hoursHigh)}';
  }
}
