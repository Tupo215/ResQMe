import 'package:flutter/material.dart';
import 'report_shared.dart';
import 'report_info_screen.dart';
import '../widgets/resq_icon.dart';

class ReportVictimScreen extends StatefulWidget {
  final String reportingFor, emergencyType;
  const ReportVictimScreen({super.key, required this.reportingFor, required this.emergencyType});
  @override
  State<ReportVictimScreen> createState() => _ReportVictimScreenState();
}

class _ReportVictimScreenState extends State<ReportVictimScreen> {
  String? _victimStatus;
  int     _count = 1;
  final   _notesCtrl = TextEditingController();

  static const List<_StatusOption> _statuses = [
    _StatusOption(ResQIcons.check,    'Conscious',   'Awake and responsive'),
    _StatusOption(ResQIcons.alert,    'Unconscious', 'Not responding'),
    _StatusOption(ResQIcons.question, 'Unknown',     'Not sure of status'),
  ];

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [
          ReportAppBar(title: 'Report Emergency',
              onBack: () => Navigator.of(context).pop()),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Victim details.',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 32,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40)),
                  const SizedBox(height: 8),
                  const Text('Help responders prepare by sharing what\nyou can see about the victim.',
                      style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                          fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40)),
                  const SizedBox(height: 32),

                  Text('Victim status', style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  for (final s in _statuses) ...[
                    GestureDetector(
                      onTap: () => setState(() => _victimStatus = s.key),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 2,
                                color: _victimStatus == s.key
                                    ? const Color(0xFF6666B3)
                                    : const Color(0xFFF3F3F5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: ShapeDecoration(
                              color: _victimStatus == s.key
                                  ? const Color(0x193663C4) : const Color(0xFFF3F3F5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999)),
                            ),
                            child: Center(child: ResQIcon(s.iconAsset, size: 22,
                                color: _victimStatus == s.key
                                    ? const Color(0xFF333399) : const Color(0xFF7B7B7B))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.label, style: TextStyle(
                                  color: _victimStatus == s.key
                                      ? const Color(0xFF333399)
                                      : Colors.black,
                                  fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                              Text(s.sub, style: const TextStyle(color: Color(0xFF7B7B7B),
                                  fontSize: 13, fontFamily: 'Inter')),
                            ],
                          )),
                          ResQIcon(
                            _victimStatus == s.key ? ResQIcons.radioFill : ResQIcons.radioOff,
                            size: 22,
                            color: _victimStatus == s.key
                                ? const Color(0xFF6666B3) : const Color(0xFFD3D3D3),
                          ),
                        ]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Text('Number of victims', style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFF3F3F5)),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Victims', style: TextStyle(color: Color(0xFF4F4F4F),
                          fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                      Row(children: [
                        GestureDetector(
                          onTap: _count > 1 ? () => setState(() => _count--) : null,
                          child: Container(
                            width: 40, height: 40,
                            decoration: ShapeDecoration(
                              color: _count > 1 ? const Color(0xFF333399) : const Color(0xFFD3D3D3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999)),
                            ),
                            child: Center(child: ResQIcon(ResQIcons.minus, size: 20, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text('$_count', style: const TextStyle(color: Color(0xFF00004D),
                            fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => setState(() => _count++),
                          child: Container(
                            width: 40, height: 40,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF333399),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999)),
                            ),
                            child: Center(child: ResQIcon(ResQIcons.add, size: 20, color: Colors.white)),
                          ),
                        ),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  Row(children: [
                    Text('Additional notes', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text('(optional)', style: TextStyle(
                        color: Colors.black,
                        fontSize: 13, fontFamily: 'Inter')),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: TextField(
                      controller: _notesCtrl, maxLines: 4,
                      style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16, fontFamily: 'Inter'),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Person is bleeding from the head, near the intersection…',
                        hintStyle: TextStyle(color: Color(0xFF7B7B7B), fontSize: 14,
                            fontFamily: 'Inter', height: 1.40),
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ReportNextButton(
              enabled: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportInfoScreen(
                    reportingFor: widget.reportingFor, emergencyType: widget.emergencyType,
                    victimStatus: _victimStatus!, victimCount: _count,
                    notes: _notesCtrl.text.trim(),
                  ))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusOption {
  final String iconAsset, label, sub;
  String get key => label.toLowerCase();
  const _StatusOption(this.iconAsset, this.label, this.sub);
}
