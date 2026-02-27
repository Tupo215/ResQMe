import 'package:flutter/material.dart';
import 'report_shared.dart';
import 'report_victim_screen.dart';
import '../widgets/resq_icon.dart';

class ReportWhatScreen extends StatefulWidget {
  final String reportingFor;
  const ReportWhatScreen({super.key, required this.reportingFor});
  @override
  State<ReportWhatScreen> createState() => _ReportWhatScreenState();
}

class _ReportWhatScreenState extends State<ReportWhatScreen> {
  String? _selected;

  static const List<_Category> _cats = [
    _Category(ResQIcons.carAccident, 'Road Accident', 'Vehicle crashes or\ntraffic incidents.'),
    _Category(ResQIcons.medical,     'Medical',       'Chest pain, breathing\nissues, etc.'),
    _Category(ResQIcons.injury,      'Fall / Injury', 'Broken bones or\nsevere falls.'),
    _Category(ResQIcons.fire,        'Fire',          'Building, vehicle, or\nbrush fires.'),
    _Category(ResQIcons.violence,    'Violence',      'Assault, robbery, or\nactive threats.'),
    _Category(ResQIcons.other,       'Other',         'Any other type of\nemergency.'),
  ];

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
                  const Text('Select what happened.',
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 32,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40)),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the category that best describes the\nsituation for faster response.',
                    style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40),
                  ),
                  const SizedBox(height: 32),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 171 / 183,
                    children: _cats.map((cat) {
                      final isSelected = _selected == cat.title;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = cat.title),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 2,
                                color: isSelected
                                    ? const Color(0xFF333399)
                                    : const Color(0xFF6666B3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: ShapeDecoration(
                                  color: isSelected
                                      ? const Color(0xFF333399)
                                      : const Color(0x193663C4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: ResQIcon(cat.iconAsset, size: 24,
                                    color: isSelected ? Colors.white : const Color(0xFF333399)),
                              ),
                              const SizedBox(height: 16),
                              Text(cat.title, style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF333399)
                                      : Colors.black.withValues(alpha: 0.20),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                              const SizedBox(height: 4),
                              Text(cat.desc, style: const TextStyle(
                                  color: Color(0xFF7B7B7B), fontSize: 12,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.40)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ReportNextButton(
              enabled: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportVictimScreen(
                    reportingFor: widget.reportingFor,
                    emergencyType: _selected!,
                  ))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Category {
  final String iconAsset, title, desc;
  const _Category(this.iconAsset, this.title, this.desc);
}
