import 'package:flutter/material.dart';
import '../widgets/resq_icon.dart';

// ─── Shared header used across all report steps ───────────────────────────────
class ReportAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const ReportAppBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 78,
    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
    decoration: const ShapeDecoration(
      color: Color(0xFFEFEFF1),
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD3D3D3))),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      GestureDetector(
        onTap: onBack,
        child: Container(
          width: 56, height: 56, padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFD3D3D3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
          ),
          child: ResQIcon(ResQIcons.chevronLeft, size: 24, color: Colors.white),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(title,
            style: TextStyle(
                color: Colors.black.withValues(alpha: 0.20),
                fontSize: 24, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
      ),
    ]),
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
