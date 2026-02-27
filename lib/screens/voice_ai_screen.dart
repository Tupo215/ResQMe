import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/location_speech_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DEPENDENCIES NEEDED IN pubspec.yaml:


//   speech_to_text: ^6.6.0
//   geolocator: ^13.0.0
// ─────────────────────────────────────────────────────────────────────────────

// ─── Waveform bar heights used throughout ─────────────────────────────────────
const List<double> _kWaveHeights = [28, 42, 28, 48, 32, 18, 28, 42, 28, 48, 32, 18, 44, 28, 20, 42, 28, 48, 32, 18, 28];

// ─── Color constants ──────────────────────────────────────────────────────────
const Color _navy        = Color(0xFF000080);
const Color _purple      = Color(0xFF6666B3);
const Color _lightPurple = Color(0xFFCCCCE6);
const Color _bg          = Color(0xFFEFEFF1);
const Color _grey        = Color(0xFFD3D3D3);
const Color _darkGrey    = Color(0xFF4F4F4F);
const Color _mutedText   = Color(0x33000000);
const Color _red         = Color(0xFFD00000);

// =============================================================================
// 1. RESQME AI WELCOME SCREEN
// =============================================================================
class VoiceAiScreen extends StatefulWidget {
  const VoiceAiScreen({super.key});
  @override
  State<VoiceAiScreen> createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveCtrl;
  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  void _openDrawer() => setState(() => _drawerOpen = true);
  void _closeDrawer() => setState(() => _drawerOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ────────────────────────────────────────
            Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openDrawer,
                        child: const Icon(Icons.menu, size: 24),
                      ),
                      const Spacer(),
                      Text('AI Name',
                          style: TextStyle(
                              color: _mutedText, fontSize: 16,
                              fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),

                const Spacer(),

                // Welcome title
                Text('Welcome to ResQMeAI',
                    style: TextStyle(
                        color: _mutedText, fontSize: 32,
                        fontFamily: 'Inter', fontWeight: FontWeight.w500,
                        height: 1.40)),

                const SizedBox(height: 72),

                // Animated waveform circle
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceChatScreen()));
                  },
                  child: Column(
                    children: [
                      // Circle with waveform inside — no mic icon
                      Container(
                        width: 120, height: 120,
                        decoration: const ShapeDecoration(
                          color: _lightPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(100))),
                        ),
                        child: Center(
                          child: _AnimatedWaveform(
                              controller: _waveCtrl, color: _purple, compact: true),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("Can't text? I can listen",
                          style: TextStyle(
                              color: _darkGrey, fontSize: 16,
                              fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Bottom input bar
                _BottomInputBar(
                  onMicTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceChatScreen()));
                  },
                ),
              ],
            ),

            // ── Sliding drawer overlay ───────────────────────────────
            if (_drawerOpen)
              GestureDetector(
                onTap: _closeDrawer,
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              left: _drawerOpen ? 0 : -300,
              top: 0, bottom: 0,
              width: 292,
              child: _SideDrawer(
                onClose: _closeDrawer,
                onSettings: () {
                  _closeDrawer();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()));
                },
                onNewChat: () {
                  _closeDrawer();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceChatScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 2. SIDE DRAWER
// =============================================================================
class _SideDrawer extends StatefulWidget {
  final VoidCallback onClose, onSettings, onNewChat;
  const _SideDrawer({required this.onClose, required this.onSettings, required this.onNewChat});
  @override
  State<_SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<_SideDrawer> {
  List<String> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatHistory = prefs.getStringList('voice_chat_history') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 20)],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: ShapeDecoration(
                  color: _grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: Row(children: [
                  const Icon(Icons.search, size: 24, color: Color(0x33000000)),
                  const SizedBox(width: 12),
                  Text('Search',
                      style: TextStyle(color: _mutedText, fontSize: 16,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                ]),
              ),
            ),

            const SizedBox(height: 8),

            // New chat
            _DrawerItem(
              icon: Icons.add,
              label: 'New chat',
              onTap: widget.onNewChat,
            ),

            // Chat history
            if (_chatHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No chats yet',
                    style: TextStyle(color: const Color(0xFF232323),
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: FontWeight.w500)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _chatHistory.length,
                  itemBuilder: (_, i) => _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: _chatHistory[i],
                    onTap: () {},
                  ),
                ),
              ),

            const Spacer(),

            // Settings
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: widget.onSettings,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 24, color: const Color(0xFF232323)),
        const SizedBox(width: 16),
        Expanded(child: Text(label,
            style: const TextStyle(color: Color(0xFF232323), fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w500))),
      ]),
    ),
  );
}

// =============================================================================
// 3. VOICE CHAT SCREEN (Live recording)
// =============================================================================
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});
  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;

  bool _isRecording = false;
  bool _speechAvailable = false;
  String _liveTranscript = '';
  String _displayText = 'Speak, I\'m listening...';

  // Waveform amplitude (driven by timer while recording)
  final List<double> _waveAmps = List.generate(21, (_) => 0.3);
  Timer? _waveTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _waveTimer?.cancel();
    SpeechService.cancel();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final ok = await SpeechService.initialize();
    if (mounted) setState(() => _speechAvailable = ok);
  }

  void _startWaveform() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted && _isRecording) {
        setState(() {
          for (int i = 0; i < _waveAmps.length; i++) {
            _waveAmps[i] = 0.2 + _random.nextDouble() * 0.8;
          }
        });
      }
    });
  }

  void _stopWaveform() {
    _waveTimer?.cancel();
    for (int i = 0; i < _waveAmps.length; i++) _waveAmps[i] = 0.3;
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _displayText = 'Listening...';
      _liveTranscript = '';
    });
    _pulseCtrl.repeat(reverse: true);
    _startWaveform();

    final started = await SpeechService.startListening(
      onResult: (text, isFinal) {
        if (mounted) {
          setState(() => _liveTranscript = text);
          if (isFinal && text.isNotEmpty) _stopRecording();
        }
      },
      onDone: () {
        if (mounted && _isRecording) _stopRecording();
      },
    );

    // If speech not available on device, show friendly message
    if (!started && mounted) {
      setState(() {
        _isRecording = false;
        _displayText = 'Microphone unavailable — type below';
      });
      _stopWaveform();
    }
  }

  void _stopRecording() {
    SpeechService.stopListening();
    _stopWaveform();
    _pulseCtrl.stop(); _pulseCtrl.reset();
    setState(() {
      _isRecording = false;
      _displayText = _liveTranscript.isNotEmpty ? _liveTranscript : 'Tap to speak again';
    });

    if (_liveTranscript.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => VoiceAiChatScreen(
                initialMessage: _liveTranscript,
              )));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const Spacer(),
                  const Text('Voice chat',
                      style: TextStyle(color: _mutedText, fontSize: 32,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text('Speak, I\'m listening...',
                style: TextStyle(color: _mutedText, fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500)),

            const SizedBox(height: 54),

            // Live recording orb
            GestureDetector(
              onTapDown: (_) => _isRecording ? null : _startRecording(),
              onTapUp: (_) => _isRecording ? _stopRecording() : null,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final scale = _isRecording
                      ? 1.0 + _pulseCtrl.value * 0.08
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 250, height: 250,
                      decoration: ShapeDecoration(
                        color: _lightPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(300))),
                      ),
                      child: Center(
                        child: Container(
                          width: 200, height: 200,
                          decoration: ShapeDecoration(
                            color: _isRecording ? _purple : const Color(0xFF8888C8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(300))),
                          ),
                          child: Center(
                            child: _isRecording
                                ? _LiveWaveformBars(amplitudes: _waveAmps)
                                : const Icon(Icons.mic_rounded,
                                    size: 64, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Live transcript
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isRecording && _liveTranscript.isNotEmpty
                      ? _liveTranscript
                      : _displayText,
                  key: ValueKey(_liveTranscript.length),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _mutedText, fontSize: 24,
                      fontFamily: 'Inter', fontWeight: FontWeight.w600,
                      height: 1.40),
                ),
              ),
            ),

            const Spacer(),

            // Bottom controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Cancel button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ),
                const SizedBox(width: 64),

                // Main mic button
                GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  onTapCancel: () => _isRecording ? _stopRecording() : null,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _isRecording ? 1.0 + _pulseCtrl.value * 0.06 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: _isRecording ? _red : _lightPurple,
                          shape: BoxShape.circle,
                          boxShadow: _isRecording ? [
                            BoxShadow(color: _red.withOpacity(0.4),
                                blurRadius: 20, spreadRadius: 4)
                          ] : null,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic_rounded,
                          size: 48,
                          color: _isRecording ? Colors.white : _navy,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 64),

                // Keyboard button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_alt_outlined, size: 24),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text('Recording...',
                        style: TextStyle(color: _darkGrey, fontSize: 16,
                            fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

            Container(
              width: 224, height: 6,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: ShapeDecoration(
                color: const Color(0xFFA7A7A7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. VOICE AI CHAT SCREEN (displays conversation)
// =============================================================================
class VoiceAiChatScreen extends StatefulWidget {
  final String initialMessage;
  const VoiceAiChatScreen({super.key, required this.initialMessage});
  @override
  State<VoiceAiChatScreen> createState() => _VoiceAiChatScreenState();
}

class _VoiceAiChatScreenState extends State<VoiceAiChatScreen> {
  bool _drawerOpen = false;
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();
  final List<_ChatMsg> _messages = [];
  bool _aiTyping = false;
  bool _isRecording = false;
  String _liveInput = '';
  bool _hasText = false;

  static const List<_AiQA> _aiFlow = [
    _AiQA('emergency', ['Starting emergency assessment', 'I\'m here with you', 'Are you safe from immediate danger (fire, traffic, smoke)?']),
    _AiQA('smoke|fire', ['If it\'s safe, turn off the engine.', 'Are you able to move?']),
    _AiQA('leg|hurt|pain', ['Okay.', 'Are you bleeding heavily?']),
    _AiQA('yes|no|dizzy', ['Stay seated and avoid standing up.', 'Is anyone else in the car with you?']),
    _AiQA('friend|passenger', ['Is your friend conscious?']),
  ];

  @override
  void initState() {
    super.initState();
    _saveToHistory(widget.initialMessage);
    _addUserMsg(widget.initialMessage);
    _triggerAiResponse(widget.initialMessage);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(String msg) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('voice_chat_history') ?? [];
    final title = msg.length > 30 ? '${msg.substring(0, 30)}...' : msg;
    if (!history.contains(title)) {
      history.insert(0, title);
      if (history.length > 20) history.removeLast();
      await prefs.setStringList('voice_chat_history', history);
    }
  }

  void _addUserMsg(String text) {
    setState(() => _messages.add(_ChatMsg(text: text, isUser: true)));
    _scrollToBottom();
  }

  void _triggerAiResponse(String userMsg) {
    setState(() => _aiTyping = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _aiTyping = false);

      // SOS detection
      final lower = userMsg.toLowerCase();
      if (lower.contains('emergency') || lower.contains('accident') ||
          lower.contains('help') || lower.contains('sos')) {
        _addAiSosBlock();
      }

      // Find matching response
      for (final qa in _aiFlow) {
        final pattern = RegExp(qa.keywords, caseSensitive: false);
        if (pattern.hasMatch(lower)) {
          for (final line in qa.responses) {
            _messages.add(_ChatMsg(text: line, isUser: false));
          }
          setState(() {});
          _scrollToBottom();
          return;
        }
      }

      // Default response
      _messages.add(_ChatMsg(
        text: 'I\'m here with you. Can you describe what\'s happening?',
        isUser: false,
      ));
      setState(() {});
      _scrollToBottom();
    });
  }

  void _addAiSosBlock() {
    _messages.add(const _ChatMsg(
      text: '__SOS_ACTIVATED__',
      isUser: false,
      isSosBlock: true,
    ));
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendText() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    _addUserMsg(text);
    _triggerAiResponse(text);
  }

  Future<void> _toggleVoiceInput() async {
    if (_isRecording) {
      await SpeechService.stopListening();
      setState(() => _isRecording = false);
      if (_liveInput.isNotEmpty) {
        final msg = _liveInput;
        setState(() => _liveInput = '');
        _addUserMsg(msg);
        _triggerAiResponse(msg);
      }
    } else {
      setState(() { _isRecording = true; _liveInput = ''; });
      await SpeechService.startListening(
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() => _liveInput = text);
            if (isFinal && text.isNotEmpty) {
              SpeechService.stopListening();
              setState(() => _isRecording = false);
              final msg = text;
              setState(() => _liveInput = '');
              _addUserMsg(msg);
              _triggerAiResponse(msg);
            }
          }
        },
        onDone: () {
          if (mounted && _isRecording) {
            setState(() => _isRecording = false);
            if (_liveInput.isNotEmpty) {
              final msg = _liveInput;
              setState(() => _liveInput = '');
              _addUserMsg(msg);
              _triggerAiResponse(msg);
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _drawerOpen = true),
                      child: const Icon(Icons.menu, size: 24),
                    ),
                    const Spacer(),
                    Text('AI Name',
                        style: TextStyle(color: _mutedText, fontSize: 16,
                            fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                  ]),
                ),

                // Chat list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    itemCount: _messages.length + (_aiTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_aiTyping && i == _messages.length) {
                        return const _TypingIndicator();
                      }
                      final msg = _messages[i];
                      if (msg.isSosBlock) return const _SosActivatedCard();
                      return _ChatBubble(msg: msg);
                    },
                  ),
                ),

                // Bottom input bar
                Container(
                  decoration: const BoxDecoration(
                    color: _bg,
                    border: Border(top: BorderSide(color: _grey, width: 1)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(children: [
                    // Symptom chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Sharp pain', 'Dull ache', 'Blurry vision',
                          'Stiff limbs', 'Chest tightness']
                            .map((s) => _SymptomChip(
                          label: s,
                          onTap: () { _addUserMsg(s); _triggerAiResponse(s); },
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input row
                    Container(
                      height: 56,
                      padding: const EdgeInsets.only(left: 24, right: 8, top: 8, bottom: 8),
                      decoration: ShapeDecoration(
                        color: _grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: _isRecording
                              ? Text(_liveInput.isNotEmpty ? _liveInput : 'Listening...',
                              style: const TextStyle(color: _darkGrey, fontSize: 16,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w500))
                              : TextField(
                            controller: _textCtrl,
                            decoration: const InputDecoration(
                              hintText: 'I feel....',
                              hintStyle: TextStyle(color: Color(0xFF7B7B7B),
                                  fontSize: 16, fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
                            onSubmitted: (_) { _sendText(); setState(() => _hasText = false); },
                          ),
                        ),
                        GestureDetector(
                          onTap: _hasText && !_isRecording
                              ? () { _sendText(); setState(() => _hasText = false); }
                              : _toggleVoiceInput,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _hasText && !_isRecording
                                  ? const Color(0xFF000080)
                                  : _isRecording ? _red : _bg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _hasText && !_isRecording
                                  ? Icons.send_rounded
                                  : _isRecording ? Icons.stop : Icons.mic_rounded,
                              size: 24,
                              color: _hasText && !_isRecording
                                  ? Colors.white
                                  : _isRecording ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      width: 224, height: 6,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFA7A7A7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            // Drawer
            if (_drawerOpen)
              GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              left: _drawerOpen ? 0 : -300,
              top: 0, bottom: 0, width: 292,
              child: _SideDrawer(
                onClose: () => setState(() => _drawerOpen = false),
                onSettings: () {
                  setState(() => _drawerOpen = false);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()));
                },
                onNewChat: () {
                  setState(() => _drawerOpen = false);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const VoiceChatScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat message model
class _ChatMsg {
  final String text;
  final bool isUser;
  final bool isSosBlock;
  const _ChatMsg({required this.text, required this.isUser, this.isSosBlock = false});
}

class _AiQA {
  final String keywords;
  final List<String> responses;
  const _AiQA(this.keywords, this.responses);
}

// SOS activated card in chat
class _SosActivatedCard extends StatelessWidget {
  const _SosActivatedCard();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: ShapeDecoration(
      color: const Color(0xFFFFF0F0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFCCCC))),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.emergency, color: _red, size: 16),
        const SizedBox(width: 8),
        const Text('SOS Activated',
            style: TextStyle(color: _red, fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        const Icon(Icons.people, color: _red, size: 16),
        const SizedBox(width: 8),
        const Text('Emergency contacts notified',
            style: TextStyle(color: _red, fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        const Icon(Icons.location_on, color: _red, size: 16),
        const SizedBox(width: 8),
        const Text('Location shared',
            style: TextStyle(color: _red, fontSize: 16,
                fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      ]),
    ]),
  );
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});
  @override
  Widget build(BuildContext context) => Align(
    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: ShapeDecoration(
        color: _grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
      ),
      child: Text(msg.text,
          style: TextStyle(color: _mutedText, fontSize: 16,
              fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.40)),
    ),
  );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: _grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _dot(0), _dot(150), _dot(300),
      ]),
    ),
  );

  Widget _dot(int delayMs) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOut,
    builder: (_, v, __) => Container(
      width: 8, height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _grey.withOpacity(0.4 + v * 0.6),
        shape: BoxShape.circle,
      ),
    ),
  );
}

class _SymptomChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SymptomChip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: _lightPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(label,
          style: const TextStyle(color: _navy, fontSize: 14,
              fontFamily: 'Inter', fontWeight: FontWeight.w500)),
    ),
  );
}

// =============================================================================
// 5. VOICE SETTINGS SCREEN
// =============================================================================
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});
  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  bool _allowLocked = true;
  bool _enableVoiceSos = true;
  bool _detectKeywords = true;
  List<String> _triggerPhrases = ['"Help me"', '"Emergency"', '"ResQMe Now"'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowLocked = prefs.getBool('voice_allow_locked') ?? true;
      _enableVoiceSos = prefs.getBool('voice_enable_sos') ?? true;
      _detectKeywords = prefs.getBool('voice_detect_keywords') ?? true;
      _triggerPhrases = prefs.getStringList('voice_trigger_phrases') ??
          ['"Help me"', '"Emergency"', '"ResQMe Now"'];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_allow_locked', _allowLocked);
    await prefs.setBool('voice_enable_sos', _enableVoiceSos);
    await prefs.setBool('voice_detect_keywords', _detectKeywords);
    await prefs.setStringList('voice_trigger_phrases', _triggerPhrases);
  }

  void _addTriggerPhrase() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPhraseSheet(
        onAdd: (phrase) {
          if (phrase.trim().isNotEmpty) {
            final formatted = '"${phrase.trim()}"';
            setState(() => _triggerPhrases.add(formatted));
            _saveSettings();
          }
        },
        onRecordAndAdd: () async {
          Navigator.pop(context);
          final result = await Navigator.push<String>(context,
              MaterialPageRoute(builder: (_) => const VoiceCalibrationScreen()));
          if (result != null && result.isNotEmpty) {
            setState(() => _triggerPhrases.add('"$result"'));
            _saveSettings();
          }
        },
      ),
    );
  }

  void _deletePhrase(int index) {
    setState(() => _triggerPhrases.removeAt(index));
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 78,
                padding: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _grey, width: 1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 56, height: 56,
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                          color: _grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Settings',
                        style: TextStyle(color: _mutedText, fontSize: 24,
                            fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── GENERAL section ──────────────────────────────────
              Text('General',
                  style: TextStyle(color: _mutedText, fontSize: 14,
                      fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              _SettingsCard(children: [
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  trailing: const Icon(Icons.chevron_right),
                  isFirst: true,
                ),
                _SettingsTile(
                  title: 'Allow activation when locked',
                  subtitle: 'Background listening even when phone is locked',
                  trailing: Switch(
                    value: _allowLocked,
                    onChanged: (v) { setState(() => _allowLocked = v); _saveSettings(); },
                    activeColor: _navy,
                  ),
                ),
                _SettingsTile(
                  title: 'Enable voice SOS',
                  subtitle: 'Trigger SOS using only your voice',
                  trailing: Switch(
                    value: _enableVoiceSos,
                    onChanged: (v) { setState(() => _enableVoiceSos = v); _saveSettings(); },
                    activeColor: _navy,
                  ),
                ),
                _SettingsTile(
                  title: 'Detect distress keyword triggers',
                  subtitle: 'Listen for selected trigger phrases',
                  trailing: Switch(
                    value: _detectKeywords,
                    onChanged: (v) { setState(() => _detectKeywords = v); _saveSettings(); },
                    activeColor: _navy,
                  ),
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),

              // ── TRIGGER PHRASES ──────────────────────────────────
              Row(children: [
                Expanded(
                  child: Text('Trigger phrases',
                      style: TextStyle(color: _mutedText, fontSize: 14,
                          fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                ),
                GestureDetector(
                  onTap: _addTriggerPhrase,
                  child: Row(children: [
                    const Icon(Icons.add, size: 20, color: _navy),
                    const SizedBox(width: 4),
                    const Text('Add new',
                        style: TextStyle(color: _navy, fontSize: 14,
                            fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),

              _SettingsCard(children: [
                for (int i = 0; i < _triggerPhrases.length; i++)
                  _SettingsTile(
                    title: _triggerPhrases[i],
                    trailing: GestureDetector(
                      onTap: () => _deletePhrase(i),
                      child: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.54), size: 20),
                    ),
                    isFirst: i == 0,
                    isLast: i == _triggerPhrases.length - 1,
                  ),
              ]),

              const SizedBox(height: 24),

              // ── VOICE CALIBRATION card ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: _bg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  shadows: const [
                    BoxShadow(color: Color(0x19000000),
                        blurRadius: 10, offset: Offset(0, 0))
                  ],
                ),
                child: Column(children: [
                  const Text('Voice Calibration',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _navy, fontSize: 24,
                          fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  const Text(
                    'Train ResQAI to recognise your unique voice pattern for higher accuracy in noisy environments',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _darkGrey, fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceCalibrationScreen())),
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: ShapeDecoration(
                        color: _navy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_rounded, color: _bg, size: 24),
                          SizedBox(width: 8),
                          Text('Train your voice',
                              style: TextStyle(color: _bg, fontSize: 16,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings card wrapper ──────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      boxShadow: [BoxShadow(color: Color(0x19000000), blurRadius: 10)],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(children: children),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isFirst, isLast;
  const _SettingsTile({
    this.icon, required this.title, this.subtitle,
    this.trailing, this.isFirst = false, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F5),
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
        topRight: isFirst ? const Radius.circular(16) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      border: isLast ? null : const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
    ),
    child: Row(children: [
      if (icon != null) ...[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: _lightPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Icon(icon, size: 24, color: _navy),
        ),
        const SizedBox(width: 16),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: _mutedText, fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(color: Color(0xFFA7A7A7),
                      fontSize: 12, fontFamily: 'Inter',
                      fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ]),
  );
}

// ── Add phrase bottom sheet ────────────────────────────────────────────────────
class _AddPhraseSheet extends StatefulWidget {
  final void Function(String) onAdd;
  final VoidCallback onRecordAndAdd;
  const _AddPhraseSheet({required this.onAdd, required this.onRecordAndAdd});
  @override
  State<_AddPhraseSheet> createState() => _AddPhraseSheetState();
}

class _AddPhraseSheetState extends State<_AddPhraseSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _grey,
                borderRadius: BorderRadius.circular(100))),
        const SizedBox(height: 24),
        const Text('Add trigger phrase',
            style: TextStyle(color: _navy, fontSize: 20,
                fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. "Call for help"',
            filled: true, fillColor: _bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.format_quote),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onRecordAndAdd,
              icon: const Icon(Icons.mic_rounded, color: _purple),
              label: const Text('Record voice',
                  style: TextStyle(color: _purple)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _purple),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onAdd(_ctrl.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              child: const Text('Add phrase',
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
          ),
        ]),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

// =============================================================================
// 6. VOICE CALIBRATION SCREEN (live recording for trigger words)
// =============================================================================
class VoiceCalibrationScreen extends StatefulWidget {
  const VoiceCalibrationScreen({super.key});
  @override
  State<VoiceCalibrationScreen> createState() => _VoiceCalibrationScreenState();
}

class _VoiceCalibrationScreenState extends State<VoiceCalibrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;

  static const List<String> _calibrationPhrases = [
    '"Help me"',
    '"Emergency"',
    '"ResQMe Now"',
  ];

  int _currentPhraseIndex = 0;
  bool _isRecording = false;
  bool _isDone = false;
  List<bool> _recorded = [false, false, false];
  String _statusText = 'Tap to record';
  String _currentRecording = '';
  final List<double> _waveAmps = List.generate(21, (_) => 0.3);
  Timer? _waveTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    SpeechService.initialize();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _waveTimer?.cancel();
    SpeechService.cancel();
    super.dispose();
  }

  void _startWaveform() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted && _isRecording) {
        setState(() {
          for (int i = 0; i < _waveAmps.length; i++) {
            _waveAmps[i] = 0.2 + _random.nextDouble() * 0.8;
          }
        });
      }
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _statusText = 'Recording...';
      _currentRecording = '';
    });
    _pulseCtrl.repeat(reverse: true);
    _startWaveform();

    await SpeechService.startListening(
      onResult: (text, isFinal) {
        if (mounted) setState(() => _currentRecording = text);
      },
      onDone: () {
        if (mounted && _isRecording) _stopRecording();
      },
    );
  }

  void _stopRecording() {
    SpeechService.stopListening();
    _waveTimer?.cancel();
    _pulseCtrl.stop(); _pulseCtrl.reset();
    for (int i = 0; i < _waveAmps.length; i++) _waveAmps[i] = 0.3;

    setState(() {
      _isRecording = false;
      _recorded[_currentPhraseIndex] = true;
    });

    if (_currentRecording.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        if (_currentPhraseIndex < _calibrationPhrases.length - 1) {
          setState(() {
            _currentPhraseIndex++;
            _statusText = 'Tap to record';
            _currentRecording = '';
          });
        } else {
          setState(() {
            _isDone = true;
            _statusText = 'Calibration complete!';
          });
          _saveCalibration();
        }
      });
    } else {
      setState(() => _statusText = 'Tap to record');
    }
  }

  Future<void> _saveCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = _calibrationPhrases.map((p) => p.replaceAll('"', '')).toList();
    await prefs.setStringList('voice_calibrated_phrases', cleaned);
    await prefs.setBool('voice_calibrated', true);
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = _calibrationPhrases[_currentPhraseIndex];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context,
                      _isDone ? _calibrationPhrases[_currentPhraseIndex].replaceAll('"', '') : null),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _grey, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                const Spacer(),
                const Text('Voice calibration',
                    style: TextStyle(color: _mutedText, fontSize: 20,
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                const Spacer(),
                const SizedBox(width: 40),
              ]),
            ),

            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_calibrationPhrases.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPhraseIndex ? 24 : 8,
                height: 8,
                decoration: ShapeDecoration(
                  color: _recorded[i] ? const Color(0xFF00A63E) :
                  (i == _currentPhraseIndex ? _navy : _grey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
              )),
            ),

            const SizedBox(height: 32),

            // Main card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: ShapeDecoration(
                    color: _bg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    shadows: const [BoxShadow(
                        color: Color(0x19000000), blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Orb
                      GestureDetector(
                        onTapDown: (_) => _isDone ? null : _startRecording(),
                        onTapUp: (_) => _isRecording ? _stopRecording() : null,
                        onTapCancel: () => _isRecording ? _stopRecording() : null,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Transform.scale(
                            scale: _isRecording ? 1.0 + _pulseCtrl.value * 0.07 : 1.0,
                            child: Container(
                              width: 250, height: 250,
                              decoration: ShapeDecoration(
                                color: _lightPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(300))),
                              ),
                              child: Center(
                                child: Container(
                                  width: 200, height: 200,
                                  decoration: ShapeDecoration(
                                    color: _isDone ? const Color(0xFF00A63E) : _purple,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(300))),
                                  ),
                                  child: Center(
                                    child: _isDone
                                        ? const Icon(Icons.check_rounded,
                                        size: 80, color: Colors.white)
                                        : (_isRecording
                                        ? _LiveWaveformBars(amplitudes: _waveAmps)
                                        : const Icon(Icons.mic_rounded,
                                        size: 64, color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Phrase to say
                      if (!_isDone) ...[
                        Text('Say: $currentPhrase',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _mutedText, fontSize: 28,
                                fontFamily: 'Inter', fontWeight: FontWeight.w500,
                                height: 1.40)),
                        const SizedBox(height: 8),
                        Text(
                          _isRecording && _currentRecording.isNotEmpty
                              ? _currentRecording
                              : 'Speak clearly at a normal volume.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _purple, fontSize: 16,
                              fontFamily: 'Inter', fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phrase ${_currentPhraseIndex + 1} of ${_calibrationPhrases.length}',
                          style: const TextStyle(color: Color(0xFFA7A7A7),
                              fontSize: 14, fontFamily: 'Inter'),
                        ),
                      ] else ...[
                        const Text('All phrases recorded!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF00A63E), fontSize: 24,
                                fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Your voice has been calibrated successfully.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _darkGrey, fontSize: 16,
                                fontFamily: 'Inter')),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Record button rings
            if (!_isDone)
              Column(children: [
                Stack(alignment: Alignment.center, children: [
                  // Outer ring
                  Container(
                    width: 168, height: 168,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _lightPurple, width: 1),
                    ),
                  ),
                  // Middle ring
                  Container(
                    width: 138, height: 138,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _lightPurple, width: 2),
                    ),
                  ),
                  // Core button
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _isRecording ? _stopRecording() : null,
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Transform.scale(
                        scale: _isRecording ? 1.0 + _pulseCtrl.value * 0.06 : 1.0,
                        child: Container(
                          width: 98, height: 98,
                          decoration: BoxDecoration(
                            color: _isRecording ? _red : _navy,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? _red : _navy).withOpacity(0.5),
                                blurRadius: 10.8,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic_rounded,
                            size: 48, color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: _isRecording ? _red : _grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRecording ? 'Recording...' : _statusText,
                      style: const TextStyle(color: _darkGrey, fontSize: 16,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ])
            else
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: ShapeDecoration(
                      color: _navy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    child: const Center(
                      child: Text('Done',
                          style: TextStyle(color: Colors.white, fontSize: 18,
                              fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Container(
              width: 224, height: 6,
              decoration: ShapeDecoration(
                color: const Color(0xFFA7A7A7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

// Animated waveform (static, uses animation controller)
class _AnimatedWaveform extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  /// When true, renders a smaller compact waveform for fitting inside a circle
  final bool compact;
  const _AnimatedWaveform({
    required this.controller, required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      // compact: fewer, shorter bars that fit inside the 120px circle
      final barCount  = compact ? 9  : _kWaveHeights.length;
      final barWidth  = compact ? 4.0 : 5.0;
      final barSpacing = compact ? 2.0 : 1.5;
      final maxH      = compact ? 28.0 : 48.0;
      final minH      = compact ? 6.0  : 8.0;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: List.generate(barCount, (i) {
          final phase = (i / barCount + controller.value) % 1.0;
          final srcH  = compact ? 1.0 : _kWaveHeights[i];
          final h = srcH * (0.5 + 0.5 * sin(phase * pi * 2));
          return Container(
            width: barWidth,
            height: h.clamp(minH, maxH),
            margin: EdgeInsets.symmetric(horizontal: barSpacing),
            decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
          );
        }),
      );
    },
  );
}

// Live waveform (uses real amplitude array)
class _LiveWaveformBars extends StatelessWidget {
  final List<double> amplitudes;
  const _LiveWaveformBars({required this.amplitudes});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: List.generate(amplitudes.length, (i) => Container(
      width: 5,
      height: (amplitudes[i] * 48).clamp(8.0, 48.0),
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: ShapeDecoration(
        color: const Color(0xFFEFEFF1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    )),
  );
}

// Bottom input bar used on welcome screen
class _BottomInputBar extends StatelessWidget {
  final VoidCallback onMicTap;
  const _BottomInputBar({required this.onMicTap});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: _bg,
      border: Border(top: BorderSide(color: _grey, width: 1)),
    ),
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
    child: Column(children: [
      // Symptom chips
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Sharp pain', 'Dull ache', 'Blurry vision',
            'Stiff limbs', 'Chest tightness']
              .map((s) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: _lightPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: Text(s, style: const TextStyle(color: _navy, fontSize: 14,
                fontFamily: 'Inter', fontWeight: FontWeight.w500)),
          ))
              .toList(),
        ),
      ),
      const SizedBox(height: 16),
      // Input row
      GestureDetector(
        onTap: onMicTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 24, right: 8, top: 8, bottom: 8),
          decoration: ShapeDecoration(
            color: _grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          ),
          child: Row(children: [
            Expanded(child: Text('I feel....',
                style: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w500))),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: _bg, shape: BoxShape.circle),
              child: const Icon(Icons.mic_rounded, size: 24, color: Colors.black54),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        width: 224, height: 6,
        decoration: ShapeDecoration(
          color: const Color(0xFFA7A7A7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
    ]),
  );
}
