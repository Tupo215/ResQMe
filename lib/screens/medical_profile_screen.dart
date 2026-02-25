import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';

class MedicalProfileScreen extends StatefulWidget {
  const MedicalProfileScreen({super.key});
  @override
  State<MedicalProfileScreen> createState() => _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends State<MedicalProfileScreen> {
  String? _bloodType;
  final Set<String> _allergies = {'Penicillin', 'Latex', 'Sulfa', 'Nuts', 'NSAID'};
  final Set<String> _conditions = {'Diabetes', 'Hypertension', 'Asthma'};
  bool _shareAllergies = true;
  bool _shareConditions = false;
  bool _shareInsurance = true;

  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _hmoController = TextEditingController();
  final _policyController = TextEditingController();
  final _instructionsController = TextEditingController(
      text: 'Patient is asthmatic. Inhaler is located in the front right pocket. Non smoker. Contact wife (Mrs patient - +234 000 000 000) immediately.');

  static const _bloodTypes = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 16, top: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFF1),
                border: Border(bottom: BorderSide(color: Color(0xFFD3D3D3))),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 56, height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD3D3D3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: ResQIcon(ResQIcons.chevronLeft, size: 24,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 64),
                Text('Medical Profile',
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 24, fontFamily: 'Inter',
                        fontWeight: FontWeight.w600, height: 1.40)),
              ]),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Info banner ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: ShapeDecoration(
                        color: AppColors.navy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        shadows: const [BoxShadow(
                            color: Color(0x19000080), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56, height: 56,
                                padding: const EdgeInsets.all(10),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF6666B3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                child: ResQIcon(ResQIcons.shieldHeart,
                                    size: 24, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'In an emergency, this information saves critical time.',
                                  style: TextStyle(
                                      color: Color(0xFFF3F3F5), fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.40),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'You have total control on who sees this information. Responders can only access this during an active SOS.',
                            style: TextStyle(color: Color(0xFFD3D3D3),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w400, height: 1.40),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Blood Type ───────────────────────────────────
                    _sectionCard(
                      iconAsset: ResQIcons.bloodtype,
                      title: 'Blood type',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Blood Type',
                              style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showBloodTypePicker(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color(0xFFA7A7A7)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(children: [
                                Expanded(child: Text(
                                    _bloodType ?? 'Select option',
                                    style: const TextStyle(
                                        color: Color(0xFF4F4F4F),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40))),
                                ResQIcon(ResQIcons.chevronDown, size: 24,
                                    color: const Color(0xFF4F4F4F)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Allergies ────────────────────────────────────
                    _sectionCard(
                      iconAsset: ResQIcons.alert,
                      title: 'Allergies',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Input all that apply',
                              style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10, runSpacing: 10,
                            children: _allergies.map((a) => _chip(a,
                                onRemove: () => setState(
                                    () => _allergies.remove(a)))).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _allergiesController,
                            style: const TextStyle(
                                color: Color(0xFF4F4F4F), fontSize: 16,
                                fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              hintText: 'Add allergies',
                              hintStyle: const TextStyle(
                                  color: Color(0xFFA7A7A7), fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFA7A7A7)),
                                borderRadius: BorderRadius.zero,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFA7A7A7)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF000080), width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: ResQIcon(ResQIcons.add, size: 20,
                                    color: AppColors.navy),
                                onPressed: () {
                                  if (_allergiesController.text.isNotEmpty) {
                                    setState(() {
                                      _allergies.add(
                                          _allergiesController.text.trim());
                                      _allergiesController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                            onSubmitted: (v) {
                              if (v.isNotEmpty) {
                                setState(() {
                                  _allergies.add(v.trim());
                                  _allergiesController.clear();
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          _shareToggle('Share with responders',
                              _shareAllergies,
                              (v) => setState(() => _shareAllergies = v)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Chronic Conditions ───────────────────────────
                    _sectionCard(
                      iconAsset: ResQIcons.medical,
                      title: 'Chronic conditions',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Input all that apply',
                              style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10, runSpacing: 10,
                            children: _conditions.map((c) => _chip(c,
                                onRemove: () => setState(
                                    () => _conditions.remove(c)))).toList(),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _conditionsController,
                            style: const TextStyle(
                                color: Color(0xFF4F4F4F), fontSize: 16,
                                fontFamily: 'Inter'),
                            decoration: InputDecoration(
                              hintText: 'Add conditions',
                              hintStyle: const TextStyle(
                                  color: Color(0xFFA7A7A7), fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 10),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFA7A7A7)),
                                borderRadius: BorderRadius.zero,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFA7A7A7)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF000080), width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: ResQIcon(ResQIcons.add, size: 20,
                                    color: AppColors.navy),
                                onPressed: () {
                                  if (_conditionsController.text.isNotEmpty) {
                                    setState(() {
                                      _conditions.add(
                                          _conditionsController.text.trim());
                                      _conditionsController.clear();
                                    });
                                  }
                                },
                              ),
                            ),
                            onSubmitted: (v) {
                              if (v.isNotEmpty) {
                                setState(() {
                                  _conditions.add(v.trim());
                                  _conditionsController.clear();
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          _shareToggle('Share with responders',
                              _shareConditions,
                              (v) => setState(() => _shareConditions = v)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── HMO / Insurance ──────────────────────────────
                    _sectionCard(
                      iconAsset: ResQIcons.shieldPlus,
                      title: 'HMO/Insurance',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _inputField('HMO / Insurance provider',
                              'e.g. Bluecross HMO', _hmoController),
                          const SizedBox(height: 24),
                          _inputField('Policy number', '00000000',
                              _policyController),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFA7A7A7)),
                          const SizedBox(height: 16),
                          _shareToggle('Share with responders',
                              _shareInsurance,
                              (v) => setState(() => _shareInsurance = v)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Emergency Instructions ───────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD00000),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        shadows: const [BoxShadow(
                            color: Color(0x19000080), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            ResQIcon(ResQIcons.alert, size: 32,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            const Text('Emergency Instructions',
                                style: TextStyle(color: Color(0xFFEFEFF1),
                                    fontSize: 24, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600, height: 1.40)),
                          ]),
                          const SizedBox(height: 15),
                          Text(_instructionsController.text,
                              style: const TextStyle(color: Color(0xFFEFEFF1),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _editInstructions(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color(0xFFCCCCE6)),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Edit',
                                      style: TextStyle(
                                          color: Color(0xFFD3D3D3),
                                          fontSize: 14, fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 1.40)),
                                  const SizedBox(width: 4),
                                  ResQIcon(ResQIcons.edit, size: 18,
                                      color: const Color(0xFFD3D3D3)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Save',
                            style: TextStyle(color: Color(0xFFEFEFF1),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500, height: 1.40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String iconAsset,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: const Color(0xFFF3F3F5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        shadows: const [BoxShadow(color: Color(0x19000000),
            blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ResQIcon(iconAsset, size: 32,
                color: Colors.black.withValues(alpha: 0.20)),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.20),
                    fontSize: 24, fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, height: 1.40)),
          ]),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _chip(String label, {required VoidCallback onRemove}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFFF3F3F5),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFD3D3D3)),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600,
                  height: 1.40)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: ResQIcon(ResQIcons.close, size: 16,
                color: const Color(0xFF7B7B7B)),
          ),
        ]),
      );

  Widget _shareToggle(String label, bool value,
      ValueChanged<bool> onChanged) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Color(0xFF4F4F4F),
                    fontSize: 16, fontFamily: 'Inter',
                    fontWeight: FontWeight.w500, height: 1.40)),
            Switch(value: value, onChanged: onChanged,
                activeColor: AppColors.navy),
          ]);

  Widget _inputField(String label, String hint,
      TextEditingController controller) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: Colors.black.withValues(alpha: 0.20),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4F4F4F),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w500),
            contentPadding: const EdgeInsets.all(16),
            filled: true, fillColor: const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFA7A7A7)),
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFA7A7A7)),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color(0xFF000080), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ]);

  void _showBloodTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Blood Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                    fontFamily: 'Inter', color: Color(0xFF00004D))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _bloodTypes.map((t) => GestureDetector(
                onTap: () {
                  setState(() => _bloodType = t);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: ShapeDecoration(
                    color: _bloodType == t
                        ? AppColors.navy : const Color(0xFFEEEEFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          color: _bloodType == t
                              ? Colors.white : AppColors.navy,
                          fontSize: 16, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _editInstructions() {
    final ctrl = TextEditingController(
        text: _instructionsController.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Instructions',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600,
                color: Color(0xFF00004D))),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy),
            onPressed: () {
              setState(() => _instructionsController.text = ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _hmoController.dispose();
    _policyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
