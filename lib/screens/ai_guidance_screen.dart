import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';

class AiGuidanceScreen extends StatefulWidget {
  const AiGuidanceScreen({super.key});
  @override
  State<AiGuidanceScreen> createState() => _AiGuidanceScreenState();
}

class _AiGuidanceScreenState extends State<AiGuidanceScreen> {
  String? _selectedEmergency;
  String? _injuredAnswer;

  static const List<_Emergency> _emergencies = [
    _Emergency(ResQIcons.carAccident,  'Vehicle accident',   'Collision or crash on the road.'),
    _Emergency(ResQIcons.injury,       'Injury or bleeding', 'Visible wounds, heavy impact or fall.'),
    _Emergency(ResQIcons.fire,         'Fire or smoke',      'Fire nearby, smoke or burning smell.'),
    _Emergency(ResQIcons.medical,      'Medical emergency',  'Chest pain, breathing trouble, unresponsive.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(children: [

            // ── Header bar ────────────────────────────────────────
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
                    child: ResQIcon(ResQIcons.bot, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('AI Emergency Assistance',
                        style: TextStyle(
                            color: Color(0xFF00000033),
                            fontSize: 24, fontFamily: 'Inter',
                            fontWeight: FontWeight.w600, height: 1.40)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── AI intro card ─────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F3F5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36, height: 40,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Center(child: ResQIcon(ResQIcons.bot,
                              size: 20, color: AppColors.navy)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Stay calm',
                                  style: TextStyle(
                                      color: Color(0xFF00004D), fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600, height: 1.40)),
                              SizedBox(height: 4),
                              Text(
                                'I will guide you step by step while\n'
                                'responders are on their way. Answer in\n'
                                'simple taps only.',
                                style: TextStyle(
                                    color: Color(0xFF4F4F4F), fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Emergency type ────────────────────────────────
                  const Text('CURRENT SITUATION',
                      style: TextStyle(color: Color(0xFF8A8F98), fontSize: 14,
                          fontFamily: 'Inter', fontWeight: FontWeight.w600,
                          height: 1.40)),
                  const SizedBox(height: 4),
                  const Text('What type of emergency is this?',
                      style: TextStyle(
                          color: Color(0xFF00000033),
                          fontSize: 16, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40)),
                  const SizedBox(height: 12),

                  ..._emergencies.map((e) {
                    final isSelected = _selectedEmergency == e.title;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmergency = e.title),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: isSelected
                              ? const Color(0xFFEEEEFF) : Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: isSelected ? 2 : 1,
                              color: isSelected
                                  ? AppColors.navy
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFEFEFF1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Center(child: ResQIcon(e.iconAsset, size: 20,
                                color: isSelected
                                    ? AppColors.navy : const Color(0xFF7B7B7B))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: TextStyle(
                                  color: isSelected
                                      ? AppColors.navy
                                      : Colors.black.withValues(alpha: 0.20),
                                  fontSize: 15, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                              Text(e.desc, style: const TextStyle(
                                  color: Color(0xFF7B7B7B), fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400, height: 1.40)),
                            ],
                          )),
                        ]),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ── Are you injured? ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Are you injured?',
                            style: TextStyle(
                                color: Color(0xFF00000033),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w600, height: 1.40)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _AnswerButton(label: 'Yes',
                              active: _injuredAnswer == 'Yes',
                              activeColor: AppColors.navy,
                              onTap: () => setState(() => _injuredAnswer = 'Yes'))),
                          const SizedBox(width: 8),
                          Expanded(child: _AnswerButton(label: 'No',
                              active: _injuredAnswer == 'No',
                              activeColor: AppColors.navy,
                              onTap: () => setState(() => _injuredAnswer = 'No'))),
                          const SizedBox(width: 8),
                          Expanded(child: _AnswerButton(label: 'Not sure',
                              active: _injuredAnswer == 'Not sure',
                              activeColor: AppColors.navy,
                              onTap: () => setState(() => _injuredAnswer = 'Not sure'))),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Do this now ───────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F7FA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Do this now',
                            style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.20),
                                fontSize: 14, fontFamily: 'Inter',
                                fontWeight: FontWeight.w600, height: 1.40)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. Move to a safe place away from traffic or\n   danger if you can.',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 14, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                              const SizedBox(height: 8),
                              Text(
                                '2. Check if you can breathe normally and\n   speak in full sentences.',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 14, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                              const SizedBox(height: 8),
                              Text(
                                '3. If others are with you, ask someone to\n   stay on lookout for responders.',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 14, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Prefer listening instead of\nreading?',
                                style: TextStyle(
                                    color: Color(0xFF7B7B7B), fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400, height: 1.40)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1,
                                      color: Colors.black.withValues(alpha: 0.08)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(children: [
                                ResQIcon(ResQIcons.volume, size: 20,
                                    color: AppColors.navy),
                                const SizedBox(width: 8),
                                Text('Play voice\nguidance',
                                    style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.20),
                                        fontSize: 13, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600, height: 1.40)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Chat with AI button ───────────────────────────
                  Container(
                    width: double.infinity, height: 50,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF000080),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResQIcon(ResQIcons.chat, size: 20,
                            color: const Color(0xFFEFEFF1)),
                        const SizedBox(width: 8),
                        const Text('Chat with AI',
                            style: TextStyle(color: Color(0xFFEFEFF1),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500, height: 1.40)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Voice, text and haptics are all active. You can put your\nphone down after starting guidance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 12,
                        fontFamily: 'Inter', fontWeight: FontWeight.w400,
                        height: 1.40),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Emergency {
  final String iconAsset, title, desc;
  const _Emergency(this.iconAsset, this.title, this.desc);
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: ShapeDecoration(
        color: active ? activeColor : Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              color: active ? activeColor : const Color(0xFF9999CC)),
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: active
                    ? const Color(0xFFEFEFF1) : const Color(0xFFA7A7A7),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w500, height: 1.40)),
      ),
    ),
  );
}
