import 'package:flutter/material.dart';
import 'package:routix_flutter/routix_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Routix
  Routix.initialize(apiKey: 'rtx_test_key_123');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RoutixMatch? _match;
  String _code = 'None';
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // 🌟 THE REACTIVE PATTERN:
    // Listen for BOTH deferred + direct attribution in one place.
    Routix.onAttribution.listen((match) {
      if (!mounted) return;

      setState(() {
        _match = match;
        _code = match.shortCode ?? 'N/A';
      });
      print('New attribution: $_code via ${match.matchSource}');
    });

    // 1️⃣ TRIGGER: Check deferred attribution on app start
    _checkDeferredAttribution();

    // 2️⃣ TRIGGER: Handle a direct deep link (Already Installed)
    // In production, pipe your link stream here:
    // final appLinks = AppLinks();
    // appLinks.uriLinkStream.listen((uri) => Routix.handleDeepLink(uri.toString()));

    // 🧪 SIMULATION (For testing purposes):
    // Simulate user clicking a deep link after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Routix.handleDeepLink('https://routix.link/SUMMER24?code=SUMMER24');
    });
  }

  Future<void> _checkDeferredAttribution() async {
    setState(() => _loading = true);

    // Resolve deferred install (Checks Referrer, Beacon, etc.)
    final match = await Routix.resolve(enableClipboard: true);

    if (!mounted) return;
    setState(() => _loading = false);
    
    if (match != null && match.success) {
      print('Deferred Attribution Found: ${match.shortCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMatch = _match != null && _match!.success;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        primaryColor: const Color(0xFF2DD4BF),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Routix SDK Example'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ATTRIBUTED CODE', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(_code, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF))),
                const SizedBox(height: 32),

                if (hasMatch) ...[
                  _InfoRow(label: 'Source', value: _match!.matchSource ?? 'N/A'),
                  _InfoRow(label: 'Confidence', value: '${((_match!.confidence ?? 0) * 100).toInt()}%'),
                  _InfoRow(label: 'Timestamp', value: _match!.timestamp?.toLocal().toString().split('.')[0] ?? 'N/A'),
                  const SizedBox(height: 32),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _checkDeferredAttribution,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_loading ? 'Checking...' : 'Check Deferred Attribution'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
