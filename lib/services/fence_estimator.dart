import 'dart:math';
import '../models/fence_models.dart';

/// Pure-function estimator – no side effects, easy to test.
class FenceEstimator {
  const FenceEstimator._();

  /// Main entry point.
  static EstimationResult estimate(FenceJobInput input) {
    final materials = <MaterialLineItem>[];
    final double slopeFactor = _slopeFactor(input.slope);
    final double adjustedFeet = input.totalLinearFeet * slopeFactor;

    switch (input.fenceType) {
      case FenceType.chainLink:
        materials.addAll(_chainLinkMaterials(input, adjustedFeet));
        break;
      case FenceType.wood:
        materials.addAll(_woodMaterials(input, adjustedFeet));
        break;
      case FenceType.vinyl:
        materials.addAll(_vinylMaterials(input, adjustedFeet));
        break;
      case FenceType.aluminum:
      case FenceType.wroughtIron:
        materials.addAll(_metalMaterials(input, adjustedFeet));
        break;
      case FenceType.compositeMixed:
        materials.addAll(_compositeMaterials(input, adjustedFeet));
        break;
    }

    // Gate materials
    for (final gate in input.gates) {
      materials.add(MaterialLineItem(
        name: '${gate.size.label} (${gate.size.widthFeet} ft)',
        quantity: gate.quantity,
        unit: 'pcs',
        note: 'Pre-built gate kit',
      ));
      materials.add(MaterialLineItem(
        name: 'Gate hinge set',
        quantity: gate.quantity,
        unit: 'sets',
      ));
      materials.add(MaterialLineItem(
        name: 'Gate latch',
        quantity: gate.quantity,
        unit: 'pcs',
      ));
    }

    final labor = _laborEstimate(input, adjustedFeet);

    return EstimationResult(
      fenceType: input.fenceType,
      linearFeet: input.totalLinearFeet,
      materials: materials,
      labor: labor,
    );
  }

  // ───────────── slope adjustment ─────────────

  static double _slopeFactor(SlopeGrade slope) {
    // More material is needed going up a slope – approximate with sec(θ).
    final rad = slope.degrees * pi / 180;
    return 1 / cos(rad);
  }

  // ───────────── posts common helper ─────────────

  static int _postCount(double linearFeet, double spacing) {
    return (linearFeet / spacing).ceil() + 1;
  }

  // ───────────── Chain-link ─────────────

  static List<MaterialLineItem> _chainLinkMaterials(
      FenceJobInput input, double ft) {
    final posts = _postCount(ft, 10); // line posts every 10 ft
    final terminalPosts = input.corners + 2; // ends + corners
    final linePosts = max(0, posts - terminalPosts);
    final meshRolls = (ft / 50).ceil(); // 50-ft rolls
    final topRailPipes = (ft / 10.5).ceil(); // 10.5 ft pipes
    final tensionBars = terminalPosts;
    final tensionBands = terminalPosts * (input.height.feet ~/ 1);
    final tieWires = (ft * 2).ceil(); // ~2 per foot

    return [
      MaterialLineItem(
          name: 'Terminal / end posts', quantity: terminalPosts, unit: 'pcs'),
      MaterialLineItem(name: 'Line posts', quantity: linePosts, unit: 'pcs'),
      MaterialLineItem(
          name: 'Chain-link mesh (50 ft rolls)',
          quantity: meshRolls,
          unit: 'rolls'),
      MaterialLineItem(
          name: 'Top rail pipe (10.5 ft)',
          quantity: topRailPipes,
          unit: 'pcs'),
      MaterialLineItem(
          name: 'Tension bars', quantity: tensionBars, unit: 'pcs'),
      MaterialLineItem(
          name: 'Tension bands', quantity: tensionBands, unit: 'pcs'),
      MaterialLineItem(name: 'Tie wires', quantity: tieWires, unit: 'pcs'),
      MaterialLineItem(
          name: 'Post caps', quantity: posts, unit: 'pcs'),
      MaterialLineItem(
          name: 'Concrete bags (50 lb)',
          quantity: posts,
          unit: 'bags',
          note: '1 bag per post'),
    ];
  }

  // ───────────── Wood ─────────────

  static List<MaterialLineItem> _woodMaterials(
      FenceJobInput input, double ft) {
    final posts = _postCount(ft, 8);
    final railCount = input.height.feet >= 6 ? posts * 3 : posts * 2;
    final pickets = (ft / 0.5).ceil(); // ~5.5 in picket + gap ≈ 6 in, so 2/ft
    final nailBoxes = (pickets / 200).ceil();

    return [
      MaterialLineItem(
          name: '4×4 posts (${input.height.feet + 2} ft)',
          quantity: posts,
          unit: 'pcs',
          note: '2 ft buried'),
      MaterialLineItem(
          name: '2×4 rails (8 ft)', quantity: railCount, unit: 'pcs'),
      MaterialLineItem(
          name: '1×6 pickets (${input.height.feet.toStringAsFixed(0)} ft)',
          quantity: pickets,
          unit: 'pcs'),
      MaterialLineItem(
          name: 'Galvanized nails (1 lb box)',
          quantity: nailBoxes,
          unit: 'boxes'),
      MaterialLineItem(
          name: 'Concrete bags (50 lb)',
          quantity: posts,
          unit: 'bags',
          note: '1 bag per post'),
      MaterialLineItem(
          name: 'Post caps', quantity: posts, unit: 'pcs'),
    ];
  }

  // ───────────── Vinyl ─────────────

  static List<MaterialLineItem> _vinylMaterials(
      FenceJobInput input, double ft) {
    final posts = _postCount(ft, 8);
    final panelSections = (ft / 8).ceil(); // 8-ft panels
    final postCaps = posts;

    return [
      MaterialLineItem(
          name: 'Vinyl posts (${input.height.feet.toStringAsFixed(0)} ft)',
          quantity: posts,
          unit: 'pcs'),
      MaterialLineItem(
          name: 'Vinyl panels (8 ft sections)',
          quantity: panelSections,
          unit: 'pcs'),
      MaterialLineItem(name: 'Post caps', quantity: postCaps, unit: 'pcs'),
      MaterialLineItem(
          name: 'Concrete bags (50 lb)',
          quantity: posts,
          unit: 'bags',
          note: '1 bag per post'),
      MaterialLineItem(
          name: 'Panel brackets', quantity: panelSections * 2, unit: 'pcs'),
    ];
  }

  // ───────────── Aluminum / wrought iron ─────────────

  static List<MaterialLineItem> _metalMaterials(
      FenceJobInput input, double ft) {
    final posts = _postCount(ft, 6); // 6-ft spacing
    final panels = (ft / 6).ceil();

    return [
      MaterialLineItem(
          name: '${input.fenceType.label} posts',
          quantity: posts,
          unit: 'pcs'),
      MaterialLineItem(
          name: '${input.fenceType.label} panels (6 ft)',
          quantity: panels,
          unit: 'pcs'),
      MaterialLineItem(name: 'Post caps', quantity: posts, unit: 'pcs'),
      MaterialLineItem(
          name: 'Mounting brackets', quantity: panels * 2, unit: 'pcs'),
      MaterialLineItem(
          name: 'Concrete bags (50 lb)',
          quantity: posts,
          unit: 'bags',
          note: '1 bag per post'),
      MaterialLineItem(
          name: 'Screws / fastener kit',
          quantity: (panels / 5).ceil(),
          unit: 'kits'),
    ];
  }

  // ───────────── Composite ─────────────

  static List<MaterialLineItem> _compositeMaterials(
      FenceJobInput input, double ft) {
    final posts = _postCount(ft, 8);
    final panels = (ft / 8).ceil();

    return [
      MaterialLineItem(
          name: 'Composite posts', quantity: posts, unit: 'pcs'),
      MaterialLineItem(
          name: 'Composite panels (8 ft)', quantity: panels, unit: 'pcs'),
      MaterialLineItem(name: 'Post caps', quantity: posts, unit: 'pcs'),
      MaterialLineItem(
          name: 'Concrete bags (50 lb)',
          quantity: posts,
          unit: 'bags',
          note: '1 bag per post'),
      MaterialLineItem(
          name: 'Panel clips', quantity: panels * 4, unit: 'pcs'),
    ];
  }

  // ───────────── Labor ─────────────

  static LaborEstimate _laborEstimate(FenceJobInput input, double ft) {
    // Base rate: feet per hour by type.
    double feetPerHourLow;
    double feetPerHourHigh;
    switch (input.fenceType) {
      case FenceType.chainLink:
        feetPerHourLow = 12;
        feetPerHourHigh = 18;
        break;
      case FenceType.wood:
        feetPerHourLow = 8;
        feetPerHourHigh = 12;
        break;
      case FenceType.vinyl:
        feetPerHourLow = 10;
        feetPerHourHigh = 15;
        break;
      case FenceType.aluminum:
      case FenceType.wroughtIron:
        feetPerHourLow = 8;
        feetPerHourHigh = 12;
        break;
      case FenceType.compositeMixed:
        feetPerHourLow = 8;
        feetPerHourHigh = 14;
        break;
    }

    // Slope adds time.
    double slopeMultiplier = 1.0;
    switch (input.slope) {
      case SlopeGrade.none:
        slopeMultiplier = 1.0;
        break;
      case SlopeGrade.mild:
        slopeMultiplier = 1.15;
        break;
      case SlopeGrade.moderate:
        slopeMultiplier = 1.30;
        break;
      case SlopeGrade.steep:
        slopeMultiplier = 1.55;
        break;
    }

    // Gate install time: ~1-2 hrs per gate.
    double gateHours = 0;
    for (final g in input.gates) {
      gateHours += g.quantity *
          (g.size == GateSize.sliding
              ? 3.0
              : g.size == GateSize.doubleGate
                  ? 2.0
                  : 1.0);
    }

    final crewSize = ft > 200 ? 3 : 2;

    final hoursLow =
        (ft / feetPerHourHigh) * slopeMultiplier + gateHours;
    final hoursHigh =
        (ft / feetPerHourLow) * slopeMultiplier + gateHours;

    final summary = _buildSummary(input, crewSize, hoursLow, hoursHigh);

    return LaborEstimate(
      hoursLow: _round(hoursLow),
      hoursHigh: _round(hoursHigh),
      crewSize: crewSize,
      summary: summary,
    );
  }

  static double _round(double v) => (v * 4).ceil() / 4; // quarter-hour

  static String _buildSummary(
      FenceJobInput input, int crew, double low, double high) {
    final buf = StringBuffer();
    buf.writeln(
        'Crew of $crew installing ${input.totalLinearFeet.toStringAsFixed(0)} linear ft of ${input.fenceType.label} fence.');
    if (input.slope != SlopeGrade.none) {
      buf.writeln('Slope (${input.slope.label}) adds extra time.');
    }
    if (input.gates.isNotEmpty) {
      final totalGates =
          input.gates.fold<int>(0, (sum, g) => sum + g.quantity);
      buf.writeln('Includes $totalGates gate(s).');
    }
    buf.writeln(
        'Estimated calendar time: ${(high / 8).ceil()} day(s) at 8 hrs/day.');
    return buf.toString().trim();
  }
}
