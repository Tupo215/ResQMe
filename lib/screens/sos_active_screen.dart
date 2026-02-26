import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_speech_service.dart';
import '../widgets/resq_widgets.dart';
import 'ai_guidance_screen.dart';
import 'sos_tracking_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SOS Active Screen — shown after 3-second hold
// Auto-refreshes after 5 seconds
// Countdown timer starts at 05:00 and counts down
// Stop Sharing: dialog differs based on whether timer is at 0 or still running
// ─────────────────────────────────────────────────────────────────────────────
class SosActiveScreen extends StatefulWidget {
  const SosActiveScreen({super.key});

  @override
  State<SosActiveScreen> createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends State<SosActiveScreen> {
  // 15 minutes in seconds
  static const _totalSeconds = 5 * 60;

  int    _secondsLeft     = _totalSeconds;
  bool   _hasRefreshed    = false;
  Timer? _countdownTimer;
  Timer? _refreshTimer;

  // Live location
  String _locationText = 'Getting location...';
  Position? _position;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
    _startCountdown();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _refreshTimer?.cancel();
    LocationService.removeListener(_onLocationUpdate);
    super.dispose();
  }

  void _onLocationUpdate(Position pos) {
    if (mounted) setState(() {
      _position = pos;
      _locationText = LocationService.formatPosition(pos);
    });
  }

  Future<void> _startLocationTracking() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _position = pos;
        _locationText = LocationService.formatPosition(pos);
      });
    } else if (mounted) {
      setState(() => _locationText = 'Location unavailable');
    }
    await LocationService.startLiveTracking(_onLocationUpdate);
  }

  // Auto-navigate to SosTrackingScreen after 5 seconds
  void _startRefreshTimer() {
    _refreshTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SosTrackingScreen()),
        );
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _timerExpired => _secondsLeft == 0;

  void _onStopSharing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _timerExpired
          ? _SosAlreadySentDialog(onOk: () => Navigator.of(context).pop())
          : _StopSharingDialog(
              onStop: () {
                Navigator.of(context).pop();
                // Return to dashboard
                Navigator.of(context).pop();
              },
              onKeep: () => Navigator.of(context).pop(),
            ),
    );
  }

  void _onAiGuidance() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiGuidanceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [

              // ── Header bar: avatar + EMERGENCY ACTIVATED ─────────
              Container(
                width: double.infinity,
                height: 78,
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                decoration: const ShapeDecoration(
                  color: Color(0xFFEFEFF1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFD3D3D3)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 56, height: 56,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD3D3D3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Icon(Icons.person, size: 24,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'EMERGENCY ACTIVATED',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.20),
                          fontSize: 24, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [

                    // ── SOS Button with rings (always showing here) ──
                    Container(
                      width: 322, height: 322,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFAE5E5), width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: 295, height: 295,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFF6CCCC), width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 230, height: 230,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD00000),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('SOS', style: TextStyle(
                                      color: Color(0xFFEFEFF1), fontSize: 64,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Help is on the way ────────────────────────────
                    const Text('Help is on the way',
                        style: TextStyle(color: Color(0xFF00004D), fontSize: 32,
                            fontFamily: 'Inter', fontWeight: FontWeight.w500,
                            height: 1.40)),
                    const SizedBox(height: 4),
                    Text('Sharing live location',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF000066), fontSize: 16,
                            fontFamily: 'Inter', fontWeight: FontWeight.w400,
                            height: 1.40)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.my_location, size: 14, color: Color(0xFF000066)),
                        const SizedBox(width: 4),
                        Text(_locationText,
                            style: const TextStyle(color: Color(0xFF000066),
                                fontSize: 13, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500)),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ── Responder card ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(children: [
                        // Avatar
                        Container(
                          width: 56, height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD3D3D3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(64)),
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('RESPONDER ASSIGNED',
                                  style: TextStyle(color: Color(0xFF7B7B7B),
                                      fontSize: 12, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.40)),
                              const Text('Joseph (Ambulance)',
                                  style: TextStyle(color: Color(0xFF00004D),
                                      fontSize: 16, fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.40)),
                              Row(children: const [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Color(0xFF4F4F4F)),
                                SizedBox(width: 4),
                                Text('Coming from Central Station',
                                    style: TextStyle(
                                        color: Color(0xFF4F4F4F),
                                        fontSize: 12, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40)),
                              ]),
                            ],
                          ),
                        ),
                        // ETA
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('6', style: TextStyle(
                                color: Color(0xFFD00000), fontSize: 24,
                                fontFamily: 'Inter', fontWeight: FontWeight.w700,
                                height: 1)),
                            Text('MINS', style: TextStyle(
                                color: Color(0xFF00004D), fontSize: 12,
                                fontFamily: 'Inter', fontWeight: FontWeight.w400,
                                height: 1.40)),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // ── Map placeholder ───────────────────────────────
                    Container(
                      width: double.infinity, height: 120,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Stack(children: [
                        // Map overlay gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.80),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Icon(Icons.location_on, size: 16,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text('Your location is pinned for Joseph',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.40)),
                            ],
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ────────────────────────────────
                    // First Aid guidance
                    GestureDetector(
                      onTap: _onAiGuidance,
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
                            Icon(Icons.medical_services_outlined,
                                size: 20, color: Color(0xFFEFEFF1)),
                            SizedBox(width: 8),
                            Text('First aid guidance',
                                style: TextStyle(color: Color(0xFFEFEFF1),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel emergency
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity, height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD00000),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cancel_outlined,
                                size: 20, color: Color(0xFFEFEFF1)),
                            SizedBox(width: 8),
                            Text('Cancel emergency',
                                style: TextStyle(color: Color(0xFFEFEFF1),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Press and hold "Cancel" for 3 seconds if this was a\nmistake. Responders are alerted of your status.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF00004D), fontSize: 12,
                        fontFamily: 'Inter', fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stop Sharing dialog (timer still running) ────────────────────────────────
class _StopSharingDialog extends StatelessWidget {
  final VoidCallback onStop;
  final VoidCallback onKeep;
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
                fontFamily: 'Inter', fontWeight: FontWeight.w600,
                height: 1.40)),
        const SizedBox(height: 12),
        const Text(
          'Your contacts will no longer receive live location updates. Emergency services are still on the way.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
              fontFamily: 'Inter', fontWeight: FontWeight.w400,
              height: 1.40),
        ),
        const SizedBox(height: 24),
        // Yes, Stop Sharing
        GestureDetector(
          onTap: onStop,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(
              color: const Color(0xFFD00000),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            child: const Center(child: Text('Yes, Stop Sharing',
                style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500,
                    height: 1.40))),
          ),
        ),
        const SizedBox(height: 12),
        // No, Keep Sharing
        GestureDetector(
          onTap: onKeep,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFF9999CC)),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Center(child: Text('No, Keep Sharing',
                style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500,
                    height: 1.40))),
          ),
        ),
      ]),
    ),
  );
}

// ─── SOS Already Sent dialog (timer expired) ─────────────────────────────────
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
                fontFamily: 'Inter', fontWeight: FontWeight.w600,
                height: 1.40)),
        const SizedBox(height: 12),
        const Text(
          'Emergency responders have been notified and are on their way. You can stop location sharing, but the emergency alert cannot be canceled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
              fontFamily: 'Inter', fontWeight: FontWeight.w400,
              height: 1.40),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onOk,
          child: Container(
            width: double.infinity, height: 50,
            decoration: ShapeDecoration(
              color: const Color(0xFF000080),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            child: const Center(child: Text('Ok',
                style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500,
                    height: 1.40))),
          ),
        ),
      ]),
    ),
  );
}
