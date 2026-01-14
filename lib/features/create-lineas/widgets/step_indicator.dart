// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<_StepData> steps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStep(i),
            if (i < steps.length - 1) _buildConnector(),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(int index) {
    final isActive = currentStep == index;
    final isCompleted = currentStep > index;
    final step = steps[index];

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isActive
                  ? Colors.blue
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : step.icon,
              color: isActive || isCompleted
                  ? Colors.white
                  : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.label,
            style: TextStyle(
              fontSize: 11,
              color: isActive || isCompleted
                  ? Colors.blue
                  : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;

  const _StepData({required this.label, required this.icon});
}

// ignore: library_private_types_in_public_api
List<_StepData> defaultSteps = const [
  _StepData(label: 'Línea', icon: Icons.directions_bus),
  _StepData(label: 'Ruta', icon: Icons.route),
  _StepData(label: 'Puntos', icon: Icons.location_on),
  _StepData(label: 'Resumen', icon: Icons.check_circle),
];
