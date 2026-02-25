import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';
import 'change_password_screen.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});
  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _gender;
  String? _ageRange;

  static const _genders   = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  static const _ageRanges = ['Under 18', '18–24', '25–34', '35–44', '45–54', '55–64', '65+'];

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
                const SizedBox(width: 16),
                Text('Personal Profile',
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // Avatar
                    Container(
                      width: 160, height: 160,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF333399),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('RM',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFEFEFF1),
                              fontSize: 48, fontFamily: 'Inter',
                              fontWeight: FontWeight.w600, height: 1.40)),
                    ),

                    const SizedBox(height: 40),

                    // Form fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputField('Full name', 'e.g. John doe', _nameCtrl),
                        const SizedBox(height: 24),
                        _inputField('Email', 'e.g. resQme.mail.com', _emailCtrl,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 24),

                        // Phone with flag
                        const Text('Phone Number',
                            style: TextStyle(color: Color(0xFF5F5F5F),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w600, height: 1.40)),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF3F3F5),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFFA7A7A7)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(children: [
                            ResQIcon(ResQIcons.flagNigeria, size: 24),
                            const SizedBox(width: 8),
                            Text('+234',
                                style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                            const SizedBox(width: 16),
                            const VerticalDivider(
                                color: Color(0xFF232323), thickness: 1,
                                indent: 12, endIndent: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                    color: Color(0xFFA7A7A7), fontSize: 16,
                                    fontFamily: 'Inter'),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 00 0000 0000',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA7A7A7),
                                      fontSize: 16, fontFamily: 'Inter'),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ]),
                        ),

                        const SizedBox(height: 24),
                        _inputField('Location', 'e.g. City, State',
                            _locationCtrl),
                        const SizedBox(height: 24),

                        // Gender dropdown
                        _dropdownField('Select gender', _gender,
                            _genders, (v) => setState(() => _gender = v)),
                        const SizedBox(height: 24),

                        // Age range dropdown
                        _dropdownField('Select age range', _ageRange,
                            _ageRanges, (v) => setState(() => _ageRange = v)),
                        const SizedBox(height: 24),

                        // Change password row
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen())),
                          child: Container(
                            height: 56,
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
                              ResQIcon(ResQIcons.lock, size: 24,
                                  color: const Color(0xFF7B7B7B)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('Change Password',
                                    style: TextStyle(color: Color(0xFF7B7B7B),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40)),
                              ),
                              ResQIcon(ResQIcons.chevronRight, size: 24,
                                  color: const Color(0xFF7B7B7B)),
                            ]),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Buttons
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Save changes',
                            style: TextStyle(color: Color(0xFFEFEFF1),
                                fontSize: 16, fontFamily: 'Inter',
                                fontWeight: FontWeight.w500, height: 1.40)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF9999CC)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Color(0xFF7B7B7B),
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

  Widget _inputField(String label, String hint,
      TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF5F5F5F),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7B7B7B),
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

  Widget _dropdownField(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF5F5F5F),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F3F5),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFA7A7A7)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(label,
                  style: const TextStyle(color: Color(0xFF4F4F4F),
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500)),
              isExpanded: true,
              icon: ResQIcon(ResQIcons.chevronDown, size: 24,
                  color: const Color(0xFF4F4F4F)),
              onChanged: onChanged,
              items: items.map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 16,
                      color: Color(0xFF4F4F4F))))).toList(),
            ),
          ),
        ),
      ]);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }
}
