import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;

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
                Text('Change Password',
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.20),
                        fontSize: 24, fontFamily: 'Inter',
                        fontWeight: FontWeight.w600, height: 1.40)),
              ]),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEEEEFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResQIcon(ResQIcons.infoOutline, size: 20,
                              color: AppColors.navy),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Your password must be at least 8 characters and include a number and a special character.',
                              style: TextStyle(color: Color(0xFF00004D),
                                  fontSize: 14, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400, height: 1.40),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _passwordField('Current password', _currentCtrl,
                        _showCurrent,
                        () => setState(() => _showCurrent = !_showCurrent)),
                    const SizedBox(height: 24),
                    _passwordField('New password', _newCtrl, _showNew,
                        () => setState(() => _showNew = !_showNew)),
                    const SizedBox(height: 24),
                    _passwordField('Confirm new password', _confirmCtrl,
                        _showConfirm,
                        () => setState(
                            () => _showConfirm = !_showConfirm)),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Update Password',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController ctrl,
      bool visible, VoidCallback onToggle) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF5F5F5F),
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: !visible,
          style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 16,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFF7B7B7B),
                fontSize: 16, fontFamily: 'Inter'),
            contentPadding: const EdgeInsets.all(16),
            filled: true, fillColor: const Color(0xFFF3F3F5),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: ResQIcon(ResQIcons.lockOutline, size: 24,
                  color: const Color(0xFF7B7B7B)),
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: ResQIcon(
                    visible ? ResQIcons.eye : ResQIcons.eyeOff,
                    size: 24, color: const Color(0xFF7B7B7B)),
              ),
            ),
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

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
