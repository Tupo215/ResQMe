import 'package:flutter/material.dart';
import '../widgets/resq_widgets.dart';
import '../widgets/resq_icon.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────────────────────────────────────
class _Tag {
  final String label; final Color bg, fg;
  const _Tag(this.label, this.bg, this.fg);
}

class _Contact {
  final String name, relationship, phone;
  final List<_Tag> tags;
  bool isPrimary, isFamily;
  _Contact({required this.name, required this.relationship,
    required this.phone, required this.tags,
    this.isPrimary = false, this.isFamily = false});
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN 1 ── Emergency Contacts list
// ─────────────────────────────────────────────────────────────────────────────
class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});
  @override State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final List<_Contact> _contacts = [];
  bool _loading = true;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _loadContactsFromApi();
  }

  // Load contacts from backend on screen open
  Future<void> _loadContactsFromApi() async {
    final result = await ResQApiService.getEmergencyContacts();
    if (!mounted) return;
    if (result.success && result.list != null) {
      final profiles = EmergencyContactProfile.fromJsonList(result.list!);
      setState(() {
        _contacts.clear();
        for (final p in profiles) {
          final rel = p.relationship.isNotEmpty ? p.relationship.first : 'Contact';
          _contacts.add(_Contact(
            name: p.name,
            relationship: rel,
            phone: p.email, // use email as display since phone not returned
            tags: [_Tag(rel, const Color(0xFFCCCCE6), AppColors.navy)],
          ));
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // Save all contacts to backend
  Future<void> _saveContactsToApi() async {
    if (_contacts.isEmpty) return;
    if (_contacts.length > 5) {
      showResQSnackBar(context, 'Maximum 5 emergency contacts allowed', isError: true);
      return;
    }
    setState(() => _saving = true);
    final inputs = _contacts.map((c) => EmergencyContactInput(
      name:         c.name,
      email:        c.phone, // phone field used as contact identifier
      relationship: c.relationship,
    )).toList();

    final result = await ResQApiService.createEmergencyContacts(inputs);
    if (!mounted) return;
    setState(() => _saving = false);
    showResQSnackBar(context, result.message, isError: !result.success);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFEFF1),
    body: SafeArea(child: Column(children: [
      // Header
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: const BoxDecoration(color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3),
                borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
            ),
          ),
          const Text('Emergency Contacts',
              style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 22,
                  fontFamily: 'Arimo', fontWeight: FontWeight.w400)),
          const SizedBox(width: 44),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('People listed here will be notified in case of an SOS alert.',
                style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 14,
                    fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40)),
          ),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.navy),
            ))
          else if (_contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text(
                  'No emergency contacts yet.\nTap Add Contact to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                      fontFamily: 'Inter'))),
            )
          else
            ..._contacts.map((c) => _contactCard(c)),
          const SizedBox(height: 120),
        ]),
      )),
      // Bottom bar
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1.27)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 50, offset: const Offset(0, 25), spreadRadius: -12)],
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => _goToAddContact(),
            child: Container(
              width: double.infinity, height: 50,
              decoration: ShapeDecoration(
                color: AppColors.navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add, color: Color(0xFFEFEFF1), size: 20),
                const SizedBox(width: 8),
                const Text('Add Contact',
                    style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD00000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
              onPressed: () {},
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ResQIcon(ResQIcons.emergency, size: 22, color: const Color(0xFFEFEFF1)),
                const SizedBox(width: 8),
                const Text('SOS- Emergency Alert',
                    style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ]),
      ),
    ])),
  );

  void _goToAddContact() async {
    if (_contacts.length >= 5) {
      showResQSnackBar(context,
          'Maximum 5 emergency contacts allowed', isError: true);
      return;
    }
    final result = await Navigator.push<_Contact>(context,
        MaterialPageRoute(builder: (_) => const AddContactScreen()));
    if (result != null) {
      setState(() => _contacts.add(result));
      // Auto-save to backend whenever a new contact is added
      _saveContactsToApi();
    }
  }

  Widget _contactCard(_Contact c) => Container(
    width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.fromLTRB(21, 21, 21, 8),
    decoration: ShapeDecoration(color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1.27, color: Color(0xFFEFEFF1)),
        borderRadius: BorderRadius.circular(16)),
      shadows: const [
        BoxShadow(color: Color(0x19000000), blurRadius: 4, offset: Offset(0, 2), spreadRadius: -2),
        BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -1),
      ]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.drag_indicator, color: Color(0xFFD3D3D3), size: 22),
        const SizedBox(width: 12),
        Container(width: 56, height: 56,
          decoration: const ShapeDecoration(color: Color(0xFFCCCCE6),
              shape: CircleBorder()),
          alignment: Alignment.center,
          child: Text(c.name[0],
              style: const TextStyle(color: AppColors.navy, fontSize: 22,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: TextStyle(color: Colors.black.withValues(alpha: 0.75),
              fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: c.tags.map((t) => _tagPill(t)).toList()),
          const SizedBox(height: 6),
          Text(c.relationship, style: const TextStyle(color: Color(0xFF7B7B7B),
              fontSize: 14, fontFamily: 'Inter')),
          Text(c.phone, style: const TextStyle(color: Color(0xFF4F4F4F),
              fontSize: 15, fontFamily: 'Inter')),
        ])),
        GestureDetector(
          onTap: () => setState(() => _contacts.remove(c)),
          child: const Padding(padding: EdgeInsets.all(4),
              child: Icon(Icons.delete_outline, color: Color(0xFFD00000), size: 24)),
        ),
      ]),
      const SizedBox(height: 10),
      Container(width: double.infinity, height: 46,
        decoration: ShapeDecoration(shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF9999CC)),
          borderRadius: BorderRadius.circular(40))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.email_outlined, color: Color(0xFF9999CC), size: 20),
          const SizedBox(width: 8),
          Text('Email', style: TextStyle(color: Colors.black.withValues(alpha: 0.35),
              fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
        ])),
      const SizedBox(height: 4),
    ]),
  );

  Widget _tagPill(_Tag t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(8)),
    child: Text(t.label, style: TextStyle(color: t.fg, fontSize: 12, fontFamily: 'Inter')));
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN 2 ── Add Contact (manual entry form)
// ─────────────────────────────────────────────────────────────────────────────
class AddContactScreen extends StatefulWidget {
  final _Contact? prefilled; // passed when coming from phonebook
  const AddContactScreen({super.key, this.prefilled});
  @override State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relCtrl   = TextEditingController();
  bool _formComplete = false;

  void _checkForm() {
    final complete = _nameCtrl.text.trim().isNotEmpty &&
                     _phoneCtrl.text.trim().isNotEmpty &&
                     _relCtrl.text.trim().isNotEmpty;
    if (complete != _formComplete) setState(() => _formComplete = complete);
  }
  final _notesCtrl = TextEditingController();
  bool _tagFamily = false;
  bool _setPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_checkForm);
    _phoneCtrl.addListener(_checkForm);
    _relCtrl.addListener(_checkForm);
    if (widget.prefilled != null) {
      _nameCtrl.text  = widget.prefilled!.name;
      _phoneCtrl.text = widget.prefilled!.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _relCtrl.dispose();  _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        decoration: const BoxDecoration(color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.27))),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Add Emergency Contact',
              style: TextStyle(fontSize: 20, fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A)))),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('Full Name'),
          _inputField(_nameCtrl, 'Enter full name'),
          const SizedBox(height: 24),
          _fieldLabel('Phone Number'),
          _inputField(_phoneCtrl, '+234 802 345 6789', type: TextInputType.phone),
          const SizedBox(height: 24),
          _fieldLabel('Relationship'),
          _inputField(_relCtrl, 'e.g. Spouse, Parent, Child, Siblings'),
          const SizedBox(height: 24),

          // Tag as Family toggle
          _toggleRow('Tag as Family', null, _tagFamily,
              (v) => setState(() => _tagFamily = v)),
          const SizedBox(height: 12),

          // Set as Primary toggle
          _toggleRow('Set as Primary Emergency Contact',
              'Automatically becomes #1 notifier',
              _setPrimary, (v) => setState(() => _setPrimary = v)),
          const SizedBox(height: 24),

          // Upload photo
          Text('Upload Photo (Optional)',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.35),
                  fontSize: 16, fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 56,
            decoration: ShapeDecoration(color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.27, color: Colors.black.withValues(alpha: 0.10)),
                borderRadius: BorderRadius.circular(14))),
            child: Row(children: [
              const SizedBox(width: 16),
              const Icon(Icons.photo_outlined, size: 24, color: Color(0xFFA7A7A7)),
              const SizedBox(width: 12),
              Text('Choose Photo', style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.35),
                  fontSize: 16, fontFamily: 'Inter')),
            ])),
          const SizedBox(height: 24),

          // Notes
          Text('Notes (Optional)',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.35),
                  fontSize: 16, fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(color: const Color(0xFFF3F3F5),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.27, color: Colors.black.withValues(alpha: 0)),
                borderRadius: BorderRadius.circular(14))),
            child: TextField(controller: _notesCtrl, maxLines: 3,
              style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
              decoration: const InputDecoration.collapsed(
                  hintText: 'Additional information...',
                  hintStyle: TextStyle(color: Color(0xFFA7A7A7),
                      fontSize: 16, fontFamily: 'Inter')))),
          const SizedBox(height: 12),

          // Or add from phonebook
          Center(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PhonebookPermissionScreen())).then((selected) {
              if (selected is _Contact) {
                Navigator.pop(context, selected);
              }
            }),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Or add from phonebook',
                  style: TextStyle(color: Color(0xFF9999CC), fontSize: 16,
                      fontFamily: 'Inter', fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline)),
            ),
          )),
          const SizedBox(height: 40),
        ]),
      )),
      // Bottom buttons
      Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        decoration: BoxDecoration(color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1.27)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 50, offset: const Offset(0, 25), spreadRadius: -12)],
        ),
        child: Row(children: [
          Expanded(child: SizedBox(height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9999CC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 16,
                      fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            ))),
          const SizedBox(width: 16),
          Expanded(child: SizedBox(height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _formComplete ? AppColors.navy : const Color(0xFFC4C4C4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40))),
              onPressed: _formComplete ? _saveContact : null,
              child: Text('Save Contact',
                  style: TextStyle(
                      color: _formComplete ? const Color(0xFFEFEFF1) : const Color(0xFF7B7B7B),
                      fontSize: 16, fontFamily: 'Inter',
                      fontWeight: FontWeight.w500)),
            ))),
        ]),
      ),
    ])),
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(color: Color(0xFF0A0A0A),
        fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w400)));

  Widget _inputField(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
    Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(color: const Color(0xFFF3F3F5),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.27, color: Colors.black.withValues(alpha: 0)),
          borderRadius: BorderRadius.circular(14))),
      child: Center(child: TextField(controller: ctrl, keyboardType: type,
        style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
        decoration: InputDecoration.collapsed(hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA7A7A7),
                fontSize: 16, fontFamily: 'Inter')))));

  Widget _toggleRow(String title, String? subtitle, bool value,
      ValueChanged<bool> onChanged) =>
    Container(width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(
              color: Colors.black.withValues(alpha: value ? 0.75 : 0.35),
              fontSize: 16, fontFamily: 'Arimo')),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF7B7B7B),
                fontSize: 13, fontFamily: 'Arimo')),
          ],
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.navy,
        ),
      ]));

  void _saveContact() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final tags = <_Tag>[];
    if (_setPrimary) tags.add(_Tag('Primary', const Color(0xFF333399), Colors.white));
    if (_tagFamily)  tags.add(_Tag('Family',  const Color(0xFFCCCCE6), AppColors.navy));
    if (tags.isEmpty) tags.add(_Tag('Contact', const Color(0xFFA7A7A7), const Color(0xFF232323)));
    final c = _Contact(name: _nameCtrl.text.trim(),
        relationship: _relCtrl.text.trim().isEmpty ? 'Contact' : _relCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        tags: tags, isPrimary: _setPrimary, isFamily: _tagFamily);
    Navigator.pop(context, c);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN 3 ── Phonebook permission dialog
// ─────────────────────────────────────────────────────────────────────────────
class PhonebookPermissionScreen extends StatelessWidget {
  const PhonebookPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF7B7B7B).withValues(alpha: 0.85),
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.27, color: Colors.black.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(16)),
          shadows: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
            BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
          ]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Allow ResQMission to access your contacts?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF0A0A0A), fontSize: 20,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text(
              'This will allow you to quickly add emergency contacts from your phone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFA7A7A7), fontSize: 15,
                  fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40)),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000080),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
              onPressed: () => _requestPermission(context),
              child: const Text('Allow', style: TextStyle(color: Color(0xFFEFEFF1),
                  fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9999CC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const PhonebookDeniedScreen())),
              child: const Text('Not Now', style: TextStyle(color: Color(0xFF7B7B7B),
                  fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            )),
        ]),
      ),
    )),
  );

  Future<void> _requestPermission(BuildContext context) async {
    // Simulate requesting permission — in production, use flutter_contacts package
    // For now, navigate directly to phonebook list (simulate granted)
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const PhonebookListScreen()));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN 4 ── Permission Denied (access denied state)
// ─────────────────────────────────────────────────────────────────────────────
class PhonebookDeniedScreen extends StatelessWidget {
  const PhonebookDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFEFF1),
    body: SafeArea(child: Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        decoration: const BoxDecoration(color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          const Text('Select from Phone',
              style: TextStyle(fontSize: 22, fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A))),
        ]),
      ),
      const Spacer(),
      const Text('Access denied. Add manually instead.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4F4F4F), fontSize: 16, fontFamily: 'Inter')),
      const SizedBox(height: 24),
      SizedBox(width: 184, height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000080),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AddContactScreen())),
          child: const Text('Manual Entry',
              style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                  fontFamily: 'Inter', fontWeight: FontWeight.w500)),
        )),
      const Spacer(),
    ])),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN 5 ── Phonebook contact list
// ─────────────────────────────────────────────────────────────────────────────
class PhonebookListScreen extends StatefulWidget {
  const PhonebookListScreen({super.key});
  @override State<PhonebookListScreen> createState() => _PhonebookListScreenState();
}

class _PhonebookListScreenState extends State<PhonebookListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Simulated phone contacts — with flutter_contacts package these come from the phone
  final List<_Contact> _phoneContacts = [
    _Contact(name: 'Alice Cooper',   relationship: '', phone: '+234 801 111 2222', tags: []),
    _Contact(name: 'Bob Martin',     relationship: '', phone: '+234 802 222 3333', tags: []),
    _Contact(name: 'Carol White',    relationship: '', phone: '+234 803 333 4444', tags: []),
    _Contact(name: 'Daniel Brown',   relationship: '', phone: '+234 804 444 5555', tags: []),
    _Contact(name: 'Emma Davis',     relationship: '', phone: '+234 805 555 6666', tags: []),
    _Contact(name: 'Frank Wilson',   relationship: '', phone: '+234 806 666 7777', tags: []),
    _Contact(name: 'Grace Lee',      relationship: '', phone: '+234 807 777 8888', tags: []),
    _Contact(name: 'Henry Clark',    relationship: '', phone: '+234 808 888 9999', tags: []),
  ];

  final Set<int> _selected = {};

  List<_Contact> get _filtered => _phoneContacts
      .where((c) => _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.phone.contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        decoration: const BoxDecoration(color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          const Text('Select from Phone',
              style: TextStyle(fontSize: 20, fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A))),
        ]),
      ),
      // Search
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Container(height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(color: const Color(0xFFF3F3F5),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.27, color: Colors.black.withValues(alpha: 0)),
              borderRadius: BorderRadius.circular(14))),
          child: Row(children: [
            const Icon(Icons.search, color: Color(0xFFA7A7A7), size: 22),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 15, fontFamily: 'Inter'),
              decoration: const InputDecoration.collapsed(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Color(0xFFA7A7A7), fontFamily: 'Arimo')))),
          ])),
      ),
      // Privacy notice
      Container(
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFCCCCE6).withValues(alpha: 0.70),
          border: Border.all(color: const Color(0xFFDBEAFE), width: 1.27)),
        child: const Center(child: Text(
          'ResQMission only accesses names and phone numbers. Permission can be revoked anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF000080), fontSize: 12, fontFamily: 'Inter'))),
      ),
      // List
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = _filtered[i];
          final idx = _phoneContacts.indexOf(c);
          final sel = _selected.contains(idx);
          return GestureDetector(
            onTap: () => setState(() => sel ? _selected.remove(idx) : _selected.add(idx)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: ShapeDecoration(
                color: sel ? const Color(0xFFEEF2FF) : Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.27,
                      color: sel ? const Color(0xFF9999CC) : const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(16))),
              child: Row(children: [
                // Checkbox
                Container(width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: sel ? AppColors.navy : const Color(0xFFD3D3D3))),
                  child: sel ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
                const SizedBox(width: 12),
                // Avatar
                Container(width: 56, height: 56,
                  decoration: const ShapeDecoration(color: AppColors.navy, shape: CircleBorder()),
                  alignment: Alignment.center,
                  child: Text(c.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(color: Color(0xFF0A0A0A),
                      fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(c.phone, style: const TextStyle(color: Color(0xFF7B7B7B),
                      fontSize: 15, fontFamily: 'Inter')),
                ])),
              ]),
            ),
          );
        },
      )),
      // Bottom action
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1.27)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 50, offset: const Offset(0, 25), spreadRadius: -12)],
        ),
        child: Column(children: [
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${_selected.length} contact${_selected.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 15, fontFamily: 'Inter'))),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selected.isEmpty
                    ? const Color(0xFFCCCCCC) : const Color(0xFF000080),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
              onPressed: _selected.isEmpty ? null : _confirmSelected,
              child: const Text('Save Selected Contacts',
                  style: TextStyle(color: Color(0xFFEFEFF1), fontSize: 16,
                      fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            )),
        ]),
      ),
    ])),
  );

  void _confirmSelected() {
    if (_selected.isEmpty) return;
    // Take first selected contact and open AddContactScreen to fill relationship
    final first = _phoneContacts[_selected.first];
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AddContactScreen(prefilled: first)));
  }
}
