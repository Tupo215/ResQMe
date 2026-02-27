import 'package:flutter/material.dart';
import '../widgets/resq_icon.dart';

// ─── Shared header used across all report steps ───────────────────────────────
class ReportAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const ReportAppBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: const ShapeDecoration(
      color: Color(0xFFEFEFF1),
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD3D3D3))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back arrow — smaller (40×40), centered with title
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40, height: 40, padding: const EdgeInsets.all(9),
            decoration: ShapeDecoration(
              color: const Color(0xFFD3D3D3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: ResQIcon(ResQIcons.chevronLeft, size: 18, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        // Title — lighter weight, vertically centered with arrow
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20, fontFamily: 'Inter',
                  fontWeight: FontWeight.w500, height: 1.30)),
        ),
      ],
    ),
  );
}

// ─── Shared Next Step / CTA button ───────────────────────────────────────────
class ReportNextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final String label;
  const ReportNextButton({
    super.key,
    required this.enabled,
    required this.onTap,
    this.label = 'Next Step',
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: double.infinity, height: 50,
      decoration: ShapeDecoration(
        color: enabled ? const Color(0xFF000080) : const Color(0xFF9999CC),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFEFEFF1), fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w500,
                height: 1.40)),
        const SizedBox(width: 8),
        ResQIcon(ResQIcons.arrowRight, size: 20, color: const Color(0xFFEFEFF1)),
      ]),
    ),
  );
}
