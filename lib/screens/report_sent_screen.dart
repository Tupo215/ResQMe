import 'package:flutter/material.dart';
import 'report_shared.dart';
import 'dashboard_screen.dart';
import '../widgets/resq_icon.dart';

class ReportSentScreen extends StatelessWidget {
  final String emergencyType;
  final int victimCount;
  final String? reporterName;
  const ReportSentScreen({super.key, required this.emergencyType,
      required this.victimCount, this.reporterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [
          ReportAppBar(title: 'Report Sent', onBack: () => Navigator.of(context).pop()),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('Help is on the way', style: TextStyle(
                      color: Colors.black,
                      fontSize: 32, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500, height: 1.40)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your report has been received and prioritized by our emergency response team.',
                    style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                        fontFamily: 'Inter', height: 1.40),
                  ),

                  const SizedBox(height: 24),

                  // ── Map + Officer card ────────────────────────────
                  Container(
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F3F5),
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFF3F3F5)),
                          borderRadius: BorderRadius.circular(12)),
                      shadows: const [BoxShadow(color: Color(0x0C000000),
                          blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Column(children: [

                      // Map
                      Container(
                        height: 192,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFFDBEAFE), Color(0xFFDCFCE7)],
                          ),
                        ),
                        child: Stack(children: [
                          Center(child: Container(
                            width: 32, height: 32,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF333399),
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 2, color: Colors.white),
                                  borderRadius: BorderRadius.circular(9999)),
                            ),
                            child: Center(child: ResQIcon(ResQIcons.locationPin,
                                size: 16, color: Colors.white)),
                          )),
                          Positioned(
                            top: 16, right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 8, height: 8,
                                    decoration: const BoxDecoration(color: Color(0xFF333399),
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('LIVE TRACKING', style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                              ]),
                            ),
                          ),
                        ]),
                      ),

                      // Officer info
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('OFFICER ASSIGNED', style: TextStyle(
                                    color: Color(0xFF7B7B7B), fontSize: 12,
                                    fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40)),
                                Text('Officer J. Doe', style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600, height: 1.40)),
                                Text('Badge #4829 • En Route', style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                              ],
                            )),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                              Text('4', style: TextStyle(color: Color(0xFF333399),
                                  fontSize: 32, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                              Text('MIN', style: TextStyle(color: Color(0xFF333399),
                                  fontSize: 14, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                              Text('ESTIMATED ETA', style: TextStyle(color: Color(0xFF9999CC),
                                  fontSize: 12, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                            ]),
                          ]),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity, height: 50,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF000080),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              ResQIcon(ResQIcons.gps, size: 20, color: const Color(0xFFEFEFF1)),
                              const SizedBox(width: 8),
                              const Text('Track Responder', style: TextStyle(
                                  color: Color(0xFFEFEFF1), fontSize: 16,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40)),
                            ]),
                          ),
                        ]),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── Incident summary ──────────────────────────────
                  const Text('INCIDENT SUMMARY', style: TextStyle(
                      color: Color(0xFF000080), fontSize: 14,
                      fontFamily: 'Inter', fontWeight: FontWeight.w600, height: 1.40)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(children: [
                      Row(children: [
                        _SummaryIcon(ResQIcons.carAccident),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('$emergencyType Reported', style: TextStyle(
                              color: Colors.black,
                              fontSize: 14, fontFamily: 'Inter',
                              fontWeight: FontWeight.w600, height: 1.40)),
                          const Text('Today, 10:42 AM', style: TextStyle(
                              color: Color(0xFF7B7B7B), fontSize: 12,
                              fontFamily: 'Inter', height: 1.40)),
                        ]),
                      ]),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1)),
                      Row(children: [
                        _SummaryIcon(ResQIcons.locationPin),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('1428 Baker St, Downtown', style: TextStyle(
                              color: Colors.black,
                              fontSize: 14, fontFamily: 'Inter',
                              fontWeight: FontWeight.w600, height: 1.40)),
                          const Text('Current Location Pin', style: TextStyle(
                              color: Color(0xFF7B7B7B), fontSize: 12,
                              fontFamily: 'Inter', height: 1.40)),
                        ]),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── While you wait ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF333399),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        ResQIcon(ResQIcons.infoOutline, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('While you wait...', style: TextStyle(
                            color: Colors.white, fontSize: 16, fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, height: 1.40)),
                      ]),
                      const SizedBox(height: 16),
                      _TipItem('1', 'Give the injured person space and prevent crowding.'),
                      const SizedBox(height: 16),
                      _TipItem('2', 'Keep your phone in your hand with the\nscreen on.'),
                      const SizedBox(height: 16),
                      _TipItem('3', 'Apply firm pressure to bleeding and keep the person still until responders arrive.'),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── Call Responder ────────────────────────────────
                  Container(
                    width: double.infinity, height: 50,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF000080),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ResQIcon(ResQIcons.phone, size: 20, color: const Color(0xFFEFEFF1)),
                      const SizedBox(width: 8),
                      const Text('Call Responder Directly', style: TextStyle(
                          color: Color(0xFFEFEFF1), fontSize: 16, fontFamily: 'Inter',
                          fontWeight: FontWeight.w500, height: 1.40)),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // ── Cancel ────────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                        (r) => false),
                    child: SizedBox(
                      width: double.infinity, height: 50,
                      child: Center(child: const Text('Cancel Request', style: TextStyle(
                          color: Color(0xFF000080), fontSize: 16, fontFamily: 'Inter',
                          fontWeight: FontWeight.w500, height: 1.40))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  final String iconAsset;
  const _SummaryIcon(this.iconAsset);
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 40,
    decoration: ShapeDecoration(
      color: const Color(0x193663C4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Center(child: ResQIcon(iconAsset, size: 20, color: const Color(0xFF333399))),
  );
}

class _TipItem extends StatelessWidget {
  final String number, text;
  const _TipItem(this.number, this.text);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 24, height: 24,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: Text(number, textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF000080), fontSize: 12,
                fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.33))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.white,
          fontSize: 14, fontFamily: 'Inter', height: 1.40))),
    ],
  );
}
