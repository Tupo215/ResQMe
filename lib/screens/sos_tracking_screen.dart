import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import 'ai_guidance_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SOS Tracking Screen — "Help is On the Way" with 15-min countdown
// Auto-refreshes after 5 seconds
// ─────────────────────────────────────────────────────────────────────────────
class SosTrackingScreen extends StatefulWidget {
  const SosTrackingScreen({super.key});

  @override
  State<SosTrackingScreen> createState() => _SosTrackingScreenState();
}

class _SosTrackingScreenState extends State<SosTrackingScreen> {
  static const _totalSecs = 15 * 60; // 15 minutes
  int    _secsLeft  = _totalSecs;
  Timer? _countdown;
  Timer? _refresh;
  bool   _refreshed = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-refresh once after 5 seconds
    _refresh = Timer(const Duration(seconds: 5),
        () { if (mounted) setState(() => _refreshed = true); });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _refresh?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (_secsLeft > 0) _secsLeft--; else t.cancel(); });
    });
  }

  String get _timerStr {
    final m = _secsLeft ~/ 60;
    final s = _secsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _expired => _secsLeft == 0;

  void _onStopSharing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _expired
          ? _SosAlreadySentDialog(onOk: () => Navigator.of(context).pop())
          : _StopSharingDialog(
              onStop: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
              onKeep: () => Navigator.of(context).pop(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(children: [

            // ── Top: avatar row + SOS ACTIVE badge ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 56, height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD3D3D3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Icon(Icons.person, size: 24, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF6CCCC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('SOS ACTIVE',
                        style: TextStyle(color: Color(0xFFD00000), fontSize: 16,
                            fontFamily: 'Inter', fontWeight: FontWeight.w400,
                            height: 1.40)),
                  ),
                  const Icon(Icons.notifications_outlined,
                      size: 24, color: AppColors.navy),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Title + subtitle ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Text('Help is On the Way',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 32, fontFamily: 'Inter',
                        fontWeight: FontWeight.w500, height: 1.40)),
                const SizedBox(height: 8),
                const Text('Responders have been dispatched to your location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 14,
                        fontFamily: 'Inter', fontWeight: FontWeight.w400,
                        height: 1.40)),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Live location timer pill ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: ShapeDecoration(
                color: const Color(0xFFEFEFF1),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      width: 1, color: Color(0x331E88E5)),
                  borderRadius: BorderRadius.circular(9999),
                ),
                shadows: const [BoxShadow(
                    color: Color(0x0C000000), blurRadius: 2,
                    offset: Offset(0, 1))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on, size: 16,
                    color: Color(0xFF6666B3)),
                const SizedBox(width: 8),
                Text(
                  'Live location sharing active ($_timerStr)',
                  style: const TextStyle(color: Color(0xFF6666B3), fontSize: 14,
                      fontFamily: 'Inter', fontWeight: FontWeight.w600,
                      height: 1.40),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // ── Map placeholder ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity, height: 221,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Stack(children: [
                  // Map background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFDBEAFE), Color(0xFFDCFCE7)],
                      ),
                    ),
                  ),
                  // Location pin
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333399),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2, color: Colors.white),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: const Icon(Icons.person,
                              size: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text('Your Current Location',
                            style: TextStyle(color: Color(0xFF232323),
                                fontSize: 14, fontFamily: 'Inter',
                                fontWeight: FontWeight.w400, height: 1.40)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 20),

            // ── Status timeline card ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(children: [
                  _TimelineItem(
                    dotColor: const Color(0xFFF0FDF4),
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'SOS sent 1 min ago',
                    status: 'Confirmed',
                    statusColor: const Color(0xFF2E7D32),
                    showLine: true,
                  ),
                  _TimelineItem(
                    dotColor: const Color(0x1922C55E),
                    icon: Icons.people_outline,
                    iconColor: const Color(0xFF22C55E),
                    title: '3 emergency contacts notified',
                    status: 'Notified',
                    statusColor: const Color(0xFF2E7D32),
                    showLine: true,
                  ),
                  _TimelineItem(
                    dotColor: const Color(0x191E88E5),
                    icon: Icons.local_shipping_outlined,
                    iconColor: const Color(0xFF1E88E5),
                    title: '1 responder assigned',
                    status: 'En Route',
                    statusColor: const Color(0xFF333399),
                    showLine: false,
                  ),

                  const SizedBox(height: 20),

                  // Live location card within timeline
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F3F5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333399),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999)),
                          ),
                          child: const Icon(Icons.location_on,
                              size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Live Location Sharing',
                                  style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.20),
                                      fontSize: 16, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400, height: 1.40)),
                              const SizedBox(height: 4),
                              const Text(
                                'Your real-time location is being shared with emergency contacts',
                                style: TextStyle(color: Color(0xFF4F4F4F),
                                    fontSize: 14, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40),
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.timer_outlined,
                                    size: 20, color: Color(0xFF4F4F4F)),
                                const SizedBox(width: 8),
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Time Remaining',
                                          style: TextStyle(
                                              color: Color(0xFF4F4F4F),
                                              fontSize: 14, fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40)),
                                      Text(_timerStr,
                                          style: const TextStyle(
                                              color: Color(0xFF333399),
                                              fontSize: 32, fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              height: 1.40)),
                                    ]),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 20),

            // ── Buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [

                // Get AI Emergency Guidance
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiGuidanceScreen()),
                  ),
                  child: Container(
                    width: double.infinity, height: 50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF000080),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.smart_toy_outlined,
                            size: 20, color: Color(0xFFEFEFF1)),
                        SizedBox(width: 8),
                        Text('Get AI Emergency Guidance',
                            style: TextStyle(color: Color(0xFFEFEFF1),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500, height: 1.40)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stop Sharing Location
                GestureDetector(
                  onTap: _onStopSharing,
                  child: Container(
                    width: double.infinity, height: 50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD00000),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: const Center(
                      child: Text('Stop Sharing Location',
                          style: TextStyle(color: Color(0xFFEFEFF1),
                              fontSize: 16, fontFamily: 'Inter',
                              fontWeight: FontWeight.w500, height: 1.40)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Green tip card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 1, color: Color(0xFFF0FDF4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Stay where you are if safe. Help has been dispatched and your contacts are aware of your situation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w400,
                        height: 1.40),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Timeline Item ────────────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final Color dotColor, iconColor, statusColor;
  final IconData icon;
  final String title, status;
  final bool showLine;

  const _TimelineItem({
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 32, height: 32,
              decoration: ShapeDecoration(
                color: dotColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999)),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            if (showLine)
              Expanded(child: Container(
                  width: 1, color: const Color(0xFFE5E7EB))),
          ]),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.20),
                    fontSize: 16, fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, height: 1.40)),
                Text(status, style: TextStyle(
                    color: statusColor, fontSize: 14, fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, height: 1.40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dialogs ──────────────────────────────────────────────────────────────────
class _StopSharingDialog extends StatelessWidget {
  final VoidCallback onStop, onKeep;
  const _StopSharingDialog({required this.onStop, required this.onKeep});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Stop Location Sharing?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text(
          'Your contacts will no longer receive live location updates. Emergency services are still on the way.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 14,
              fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40),
        ),
        const SizedBox(height: 20),
        GestureDetector(onTap: onStop,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(color: const Color(0xFFD00000),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40))),
            child: const Center(child: Text('Yes, Stop Sharing',
                style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500))),
          )),
        const SizedBox(height: 12),
        GestureDetector(onTap: onKeep,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF9999CC)),
                    borderRadius: BorderRadius.circular(40))),
            child: const Center(child: Text('No, Keep Sharing',
                style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500))),
          )),
      ]),
    ),
  );
}

class _SosAlreadySentDialog extends StatelessWidget {
  final VoidCallback onOk;
  const _SosAlreadySentDialog({required this.onOk});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('SOS Already Sent',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text(
          'Emergency responders have been notified and are on their way. You can stop location sharing, but the emergency alert cannot be canceled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 14,
              fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40),
        ),
        const SizedBox(height: 20),
        GestureDetector(onTap: onOk,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(color: const Color(0xFF000080),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40))),
            child: const Center(child: Text('Ok',
                style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500))),
          )),
      ]),
    ),
  );
}
