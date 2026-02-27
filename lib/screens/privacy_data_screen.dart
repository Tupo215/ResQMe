import 'package:flutter/material.dart';
import '../widgets/resq_icon.dart';
import '../widgets/resq_widgets.dart';

// ─── Shared prefs key to persist privacy settings across the app ──────────────
// Used by SettingsScreen to read/write these values globally via a callback
// Pass an onToggleChanged callback so Settings can react instantly

class PrivacyDataScreen extends StatefulWidget {
  /// Optional: called when any toggle changes so caller can react
  final void Function(bool sosTracking, bool contacts, bool responders,
      bool bloodType, bool allergies, bool profileIdentity)? onChanged;

  const PrivacyDataScreen({super.key, this.onChanged});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  // Location toggles
  bool _sosTracking   = true;
  bool _contacts      = true;
  bool _responders    = true;
  // Medical toggles
  bool _bloodType     = true;
  bool _allergies     = true;
  // Personal toggles
  bool _profileIdentity = true;

  void _notify() {
    widget.onChanged?.call(_sosTracking, _contacts, _responders,
        _bloodType, _allergies, _profileIdentity);
  }

  void _withdrawAll() {
    setState(() {
      _sosTracking = _contacts = _responders = false;
      _bloodType   = _allergies = false;
      _profileIdentity = false;
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFF1),
                border: Border(bottom: BorderSide(color: Color(0xFFD3D3D3))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 56, height: 56,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD3D3D3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: ResQIcon(ResQIcons.chevronLeft, size: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Privacy & data',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24, fontFamily: 'Inter',
                          fontWeight: FontWeight.w600, height: 1.40)),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Headline
                    const Text('Your data.\nYour rules.',
                        style: TextStyle(color: Color(0xFF000080),
                            fontSize: 32, fontFamily: 'Inter',
                            fontWeight: FontWeight.w500, height: 1.40)),
                    const SizedBox(height: 12),
                    const Text(
                        'Control exactly what information is shared during\nemergency missions.',
                        style: TextStyle(color: Color(0xFF7B7B7B),
                            fontSize: 14, fontFamily: 'Inter',
                            fontWeight: FontWeight.w400, height: 1.40)),

                    const SizedBox(height: 40),

                    // ── LOCATION ─────────────────────────────────────
                    _sectionHeader(ResQIcons.locationPin, 'LOCATION'),
                    const SizedBox(height: 16),
                    _toggleCard([
                      _ToggleItem(
                        title: 'SOS Tracking',
                        subtitle: 'Allows responders to find you faster',
                        value: _sosTracking,
                        onChanged: (v) { setState(() => _sosTracking = v); _notify(); },
                      ),
                      _ToggleItem(
                        title: 'Contacts',
                        subtitle: 'Notify your emergency contacts',
                        value: _contacts,
                        onChanged: (v) { setState(() => _contacts = v); _notify(); },
                      ),
                      _ToggleItem(
                        title: 'Responders',
                        subtitle: 'Share live coordinates with HQ',
                        value: _responders,
                        onChanged: (v) { setState(() => _responders = v); _notify(); },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // ── MEDICAL INFO ──────────────────────────────────
                    _sectionHeader(ResQIcons.healthMetrics, 'MEDICAL INFO'),
                    const SizedBox(height: 16),
                    _toggleCard([
                      _ToggleItem(
                        title: 'Blood type',
                        subtitle: 'Shared only during active mission',
                        value: _bloodType,
                        onChanged: (v) { setState(() => _bloodType = v); _notify(); },
                      ),
                      _ToggleItem(
                        title: 'Allergies',
                        subtitle: 'Known allergies and conditions',
                        value: _allergies,
                        onChanged: (v) { setState(() => _allergies = v); _notify(); },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // ── PERSONAL INFO ─────────────────────────────────
                    _sectionHeader(ResQIcons.userSolid, 'PERSONAL INFO'),
                    const SizedBox(height: 16),
                    _toggleCard([
                      _ToggleItem(
                        title: 'Profile Identity',
                        subtitle: 'Legal name and identification photo',
                        value: _profileIdentity,
                        onChanged: (v) { setState(() => _profileIdentity = v); _notify(); },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // ── Action buttons ─────────────────────────────────
                    // Preview button (active — navy filled)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => _PreviewDialog(
                            sosTracking: _sosTracking,
                            contacts: _contacts,
                            bloodType: _bloodType,
                            allergies: _allergies,
                            profileIdentity: _profileIdentity,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF000080),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResQIcon(ResQIcons.eye, size: 22,
                                color: const Color(0xFFEFEFF1)),
                            const SizedBox(width: 8),
                            const Text('Preview what responders see',
                                style: TextStyle(color: Color(0xFFEFEFF1),
                                    fontSize: 16, fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500, height: 1.40)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Withdraw all consents (red text)
                    GestureDetector(
                      onTap: _withdrawAll,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        child: const Center(
                          child: Text('Withdraw all consents',
                              style: TextStyle(color: Color(0xFFD00000),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500, height: 1.40)),
                        ),
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

  Widget _sectionHeader(String icon, String label) {
    return Row(children: [
      ResQIcon(icon, size: 20, color: const Color(0xFF000080)),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(color: Color(0xFF000080),
              fontSize: 12, fontFamily: 'Inter',
              fontWeight: FontWeight.w500, height: 1.40)),
    ]);
  }

  Widget _toggleCard(List<_ToggleItem> items) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 12,
              offset: Offset(0, 4), spreadRadius: 0)
        ],
      ),
      child: Column(
        children: items.map((item) => _buildToggleRow(item)).toList(),
      ),
    );
  }

  Widget _buildToggleRow(_ToggleItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: item.isLast
          ? null
          : const ShapeDecoration(
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFF8FAFC)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.20),
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w600, height: 1.40)),
              Text(item.subtitle,
                  style: const TextStyle(color: Color(0xFF7B7B7B),
                      fontSize: 12, fontFamily: 'Inter',
                      fontWeight: FontWeight.w400, height: 1.40)),
            ],
          ),
          _ResQSwitch(value: item.value, onChanged: item.onChanged),
        ],
      ),
    );
  }
}

// ─── Toggle item model ────────────────────────────────────────────────────────
class _ToggleItem {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;
  const _ToggleItem({
    required this.title, required this.subtitle,
    required this.value, required this.onChanged,
    this.isLast = false,
  });
}

// ─── Custom navy switch matching the design ───────────────────────────────────
class _ResQSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ResQSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50, height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF000080) : const Color(0xFFC4C4C4),
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Preview dialog ───────────────────────────────────────────────────────────
class _PreviewDialog extends StatelessWidget {
  final bool sosTracking, contacts, bloodType, allergies, profileIdentity;
  const _PreviewDialog({
    required this.sosTracking, required this.contacts,
    required this.bloodType,  required this.allergies,
    required this.profileIdentity,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What responders will see',
                style: TextStyle(color: Color(0xFF000080),
                    fontSize: 18, fontFamily: 'Inter',
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _previewRow('Live location', sosTracking),
            _previewRow('Emergency contacts notified', contacts),
            _previewRow('Blood type', bloodType),
            _previewRow('Allergies', allergies),
            _previewRow('Profile identity', profileIdentity),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000080),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close',
                    style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel_outlined,
          size: 20,
          color: enabled ? const Color(0xFF2E7D32) : const Color(0xFFC4C4C4),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: enabled ? Colors.black87 : const Color(0xFF7B7B7B),
                fontSize: 15, fontFamily: 'Inter',
                fontWeight: FontWeight.w400)),
      ]),
    );
  }
}
