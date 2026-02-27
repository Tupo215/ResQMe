import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';
import '../services/api_service.dart';
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
  bool _loading = true;

  static const _genders   = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  static const _ageRanges = ['Under 18', '18–24', '25–34', '35–44', '45–54', '55–64', '65+'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Populate from local cache first (instant), then refresh from API ────────
  Future<void> _loadProfile() async {
    // Step 1: fill immediately from SharedPreferences so screen isn't blank
    final cached  = await ResQApiService.getCachedProfile();
    final name    = await ResQApiService.getUserName();
    final email   = await ResQApiService.getUserEmail();
    _applyData(cached, fallbackName: name, fallbackEmail: email);

    // Step 2: fetch latest from server and update if successful
    final result = await ResQApiService.getMyProfile();
    if (result.success && result.data != null) {
      _applyData(result.data);
    }

    if (mounted) setState(() => _loading = false);
  }

  void _applyData(Map<String, dynamic>? data,
      {String? fallbackName, String? fallbackEmail}) {
    if (data == null && fallbackName == null && fallbackEmail == null) return;
    if (!mounted) return;

    setState(() {
      // Full name
      final name = data?['fullname'] ?? fallbackName ?? '';
      if (name.toString().isNotEmpty) _nameCtrl.text = name;

      // Email
      final emailVal = data?['email'] ?? fallbackEmail ?? '';
      if (emailVal.toString().isNotEmpty) _emailCtrl.text = emailVal;

      // Phone — strip leading +234 so only the local number shows
      final phone = (data?['phone'] ?? data?['phoneNumber'] ?? '').toString();
      if (phone.isNotEmpty) {
        _phoneCtrl.text = phone.startsWith('+234')
            ? phone.substring(4).trim()
            : phone;
      }

      // Location — prefer city+country, fall back to address
      final city    = (data?['city']    ?? '').toString();
      final country = (data?['country'] ?? '').toString();
      final address = (data?['address'] ?? '').toString();
      if (city.isNotEmpty || country.isNotEmpty) {
        _locationCtrl.text = [city, country]
            .where((s) => s.isNotEmpty).join(', ');
      } else if (address.isNotEmpty) {
        _locationCtrl.text = address;
      }

      // Gender — match case-insensitively to our dropdown list
      final g = (data?['gender'] ?? '').toString().toLowerCase();
      if (g.isNotEmpty) {
        _gender = _genders.firstWhere(
            (v) => v.toLowerCase() == g, orElse: () => _gender ?? '');
        if (_gender!.isEmpty) _gender = null;
      }

      // Age range — from int age or ISO birthDate string
      final ageRaw = data?['age'];
      if (ageRaw != null) {
        final a = int.tryParse(ageRaw.toString());
        if (a != null) _ageRange = _bucketAge(a);
      }
      if (_ageRange == null) {
        final dob = (data?['birthDate'] ?? '').toString();
        if (dob.isNotEmpty) {
          try {
            final years =
                DateTime.now().difference(DateTime.parse(dob)).inDays ~/ 365;
            _ageRange = _bucketAge(years);
          } catch (_) {}
        }
      }
    });
  }

  String _bucketAge(int age) {
    if (age < 18)  return 'Under 18';
    if (age <= 24) return '18–24';
    if (age <= 34) return '25–34';
    if (age <= 44) return '35–44';
    if (age <= 54) return '45–54';
    if (age <= 64) return '55–64';
    return '65+';
  }

  // Generate initials from whatever name is loaded
  String _initials() {
    final parts = _nameCtrl.text.trim().split(' ')
        .where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RM';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────────────────
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
              const Text('Personal Profile',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24, fontFamily: 'Inter',
                      fontWeight: FontWeight.w600, height: 1.40)),
            ]),
          ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF000080)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // Avatar — initials derived from loaded name
                        Container(
                          width: 160, height: 160,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF333399),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                          ),
                          alignment: Alignment.center,
                          child: Text(_initials(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFEFEFF1),
                                  fontSize: 48, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600, height: 1.40)),
                        ),

                        const SizedBox(height: 40),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _inputField('Full name', 'e.g. John Doe', _nameCtrl),
                            const SizedBox(height: 24),

                            _inputField('Email', 'e.g. you@email.com', _emailCtrl,
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 24),

                            // ── Phone with flag ──────────────────────
                            const Text('Phone Number',
                                style: TextStyle(color: Colors.black,
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
                                const Text('+234',
                                    style: TextStyle(
                                        color: Color(0xFF4F4F4F),
                                        fontSize: 16, fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.40)),
                                const SizedBox(width: 16),
                                const VerticalDivider(
                                    color: Color(0xFF232323), thickness: 1,
                                    indent: 12, endIndent: 12),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    // grey typed text
                                    style: const TextStyle(
                                        color: Color(0xFF4F4F4F),
                                        fontSize: 16, fontFamily: 'Inter'),
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 00 0000 0000',
                                      hintStyle: TextStyle(
                                          color: Color(0xFF7B7B7B),
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

                            _dropdownField('Select gender', _gender,
                                _genders,
                                (v) => setState(() => _gender = v)),
                            const SizedBox(height: 24),

                            _dropdownField('Select age range', _ageRange,
                                _ageRanges,
                                (v) => setState(() => _ageRange = v)),
                            const SizedBox(height: 24),

                            // ── Change Password ──────────────────────
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ChangePasswordScreen())),
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
                                      color: Colors.black),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Change Password',
                                        style: TextStyle(color: Colors.black,
                                            fontSize: 16, fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            height: 1.40)),
                                  ),
                                  ResQIcon(ResQIcons.chevronRight, size: 24,
                                      color: Colors.black),
                                ]),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── Save / Cancel buttons ────────────────────
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
                                style: TextStyle(color: Colors.black,
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  // ── Input field: grey typed text + grey hint ───────────────────────────────
  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Colors.black,
                fontSize: 16, fontFamily: 'Inter',
                fontWeight: FontWeight.w600, height: 1.40)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(
              color: Color(0xFF4F4F4F),  // grey typed text
              fontSize: 16, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFF7B7B7B),  // lighter grey placeholder
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

  // ── Dropdown: grey hint + grey selected text ───────────────────────────────
  Widget _dropdownField(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Colors.black,
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
                  style: const TextStyle(
                      color: Color(0xFF7B7B7B),  // grey placeholder
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500)),
              isExpanded: true,
              icon: ResQIcon(ResQIcons.chevronDown, size: 24,
                  color: const Color(0xFF7B7B7B)),
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
