import 'package:flutter/material.dart';
import 'pages/estimation_input_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FenceEstimatorApp());
}

class FenceEstimatorApp extends StatelessWidget {
  const FenceEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fence Estimator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const EstimationInputPage(),
    );
  }
}
