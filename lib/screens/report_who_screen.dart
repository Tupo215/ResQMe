import 'package:flutter/material.dart';
import 'report_shared.dart';
import 'report_what_screen.dart';
import '../widgets/resq_icon.dart';

class ReportWhoScreen extends StatefulWidget {
  const ReportWhoScreen({super.key});
  @override
  State<ReportWhoScreen> createState() => _ReportWhoScreenState();
}

class _ReportWhoScreenState extends State<ReportWhoScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [
          ReportAppBar(title: 'Report for Someone',
              onBack: () => Navigator.of(context).pop()),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Info banner ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0x193663C4),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0x193663C4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF333399),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999)),
                        ),
                        child: ResQIcon(ResQIcons.shieldHeart, size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("You're doing the right thing",
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600, height: 1.40)),
                            const Text(
                              'We are here to help you through this\nprocess step by step.',
                              style: TextStyle(color: Color(0xFF7B7B7B),
                                  fontSize: 14, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400, height: 1.40),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  Text('Who are you reporting for?',
                      style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.20),
                          fontSize: 24, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40)),
                  const SizedBox(height: 16),

                  _WhoCard(
                    iconAsset: ResQIcons.userMultiple,
                    title: 'Someone I know',
                    subtitle: 'Friend, family member, or\ncolleague',
                    activeIconBg: const Color(0x193663C4),
                    activeIconColor: const Color(0xFF333399),
                    selected: _selected == 'known',
                    onTap: () => setState(() => _selected = 'known'),
                  ),
                  const SizedBox(height: 16),
                  _WhoCard(
                    iconAsset: ResQIcons.userSolid,
                    title: 'A stranger',
                    subtitle: "Someone you don't personally\nknow",
                    activeIconBg: const Color(0xFF000080),
                    activeIconColor: Colors.white,
                    selected: _selected == 'stranger',
                    onTap: () => setState(() => _selected = 'stranger'),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ReportNextButton(
              enabled: _selected != null,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportWhatScreen(reportingFor: _selected!))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _WhoCard extends StatelessWidget {
  final String iconAsset;
  final Color activeIconBg, activeIconColor;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _WhoCard({
    required this.iconAsset,
    required this.activeIconBg,
    required this.activeIconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: selected ? const Color(0xFF6666B3) : const Color(0xFFF3F3F5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: ShapeDecoration(
            color: selected ? activeIconBg : const Color(0x193663C4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          ),
          child: Center(child: ResQIcon(iconAsset, size: 24,
              color: selected ? activeIconColor : const Color(0xFF333399))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
                color: Colors.black.withValues(alpha: 0.20),
                fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600, height: 1.40)),
            Text(subtitle, style: const TextStyle(color: Color(0xFF7B7B7B),
                fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40)),
          ],
        )),
        ResQIcon(
          selected ? ResQIcons.radioFill : ResQIcons.radioOff,
          size: 24,
          color: selected ? const Color(0xFF6666B3) : const Color(0xFFD3D3D3),
        ),
      ]),
    ),
  );
}
