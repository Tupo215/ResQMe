import 'package:flutter/material.dart';
import 'report_shared.dart';
import 'report_sent_screen.dart';
import '../widgets/resq_icon.dart';
import '../widgets/resq_widgets.dart';
import '../services/api_service.dart';
import '../services/location_speech_service.dart';

class ReportInfoScreen extends StatefulWidget {
  final String reportingFor, emergencyType, victimStatus;
  final int victimCount;
  final String notes;
  const ReportInfoScreen({super.key, required this.reportingFor,
    required this.emergencyType, required this.victimStatus,
    required this.victimCount, required this.notes});
  @override
  State<ReportInfoScreen> createState() => _ReportInfoScreenState();
}

class _ReportInfoScreenState extends State<ReportInfoScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool  _anonymous    = false;
  bool  _isSubmitting = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Get live GPS location
    final position = await LocationService.getCurrentPosition();

    final result = await ResQApiService.reportEmergency(
      // Confirmed required fields (image 2)
      latitude:      position?.latitude  ?? 0.0,
      longitude:     position?.longitude ?? 0.0,
      // Additional context
      emergencyType: widget.emergencyType,
      reportingFor:  widget.reportingFor,
      description:   widget.notes.isNotEmpty ? widget.notes : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ReportSentScreen(
            emergencyType: widget.emergencyType,
            victimCount:   widget.victimCount,
            reporterName:  _anonymous ? null : _nameCtrl.text.trim(),
          )));
    } else {
      showResQSnackBar(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [
          ReportAppBar(title: 'Reporter Information',
              onBack: () => Navigator.of(context).pop()),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 23, left: 16, right: 16, bottom: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Your Information', style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.20),
                          fontSize: 32, fontFamily: 'Inter',
                          fontWeight: FontWeight.w500, height: 1.40)),
                      const SizedBox(height: 8),
                      const Text(
                        'Adding your details helps us follow up with\nupdates on your report, but it is entirely\noptional.',
                        style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                            fontFamily: 'Inter', height: 1.40),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('FULL NAME (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _InputField(controller: _nameCtrl, hint: 'e.g. John Doe',
                      enabled: !_anonymous, keyboardType: TextInputType.name),
                  const SizedBox(height: 24),

                  _FieldLabel('PHONE NUMBER (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _InputField(controller: _phoneCtrl, hint: '+1 (555) 000-0000',
                      enabled: !_anonymous, keyboardType: TextInputType.phone),
                  const SizedBox(height: 24),

                  // ── Anonymous toggle ──────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() {
                      _anonymous = !_anonymous;
                      if (_anonymous) { _nameCtrl.clear(); _phoneCtrl.clear(); }
                    }),
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1,
                              color: _anonymous
                                  ? const Color(0xFF333399) : const Color(0xFF9999CC)),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        ResQIcon(
                          _anonymous ? ResQIcons.checkboxChecked : ResQIcons.checkboxUnchecked,
                          size: 20,
                          color: _anonymous ? const Color(0xFF333399) : const Color(0xFF9999CC),
                        ),
                        const SizedBox(width: 8),
                        Text('I prefer to report anonymously', style: TextStyle(
                            color: _anonymous
                                ? const Color(0xFF333399) : const Color(0xFF9999CC),
                            fontSize: 16, fontFamily: 'Inter',
                            fontWeight: FontWeight.w500, height: 1.40)),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Privacy banner ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0x193663C4),
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0x193663C4)),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ResQIcon(ResQIcons.shieldLock, size: 24, color: const Color(0xFF333399)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                        Text('Privacy Commitment', style: TextStyle(color: Color(0xFF0F172A),
                            fontSize: 14, fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, height: 1.40)),
                        SizedBox(height: 4),
                        Text(
                          'Your data is encrypted and protected. We never\nshare your identity without explicit permission\nfrom you.',
                          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 12,
                              fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40),
                        ),
                      ])),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // ── Continue button ───────────────────────────────
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitReport,
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: ShapeDecoration(
                        color: _isSubmitting
                            ? const Color(0xFF7B7B7B)
                            : const Color(0xFF000080),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      child: _isSubmitting
                          ? const Center(child: SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)))
                          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text('Submit Emergency Report', style: TextStyle(
                                  color: Color(0xFFEFEFF1), fontSize: 16,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w500,
                                  height: 1.40)),
                              const SizedBox(width: 8),
                              ResQIcon(ResQIcons.arrowRight, size: 20,
                                  color: const Color(0xFFEFEFF1)),
                            ]),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
      color: Colors.black.withValues(alpha: 0.20),
      fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType? keyboardType;
  const _InputField({required this.controller, required this.hint,
      required this.enabled, this.keyboardType});
  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    decoration: ShapeDecoration(
      color: enabled ? Colors.white : const Color(0xFFF3F3F5),
      shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(12)),
    ),
    child: TextField(
      controller: controller, enabled: enabled, keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16, fontFamily: 'Inter'),
      decoration: InputDecoration(hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
              fontFamily: 'Inter', height: 1.40),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          border: InputBorder.none),
    ),
  );
}
