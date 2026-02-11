import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceListeningSheet extends StatefulWidget {
  const VoiceListeningSheet({super.key});

  @override
  State<VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<VoiceListeningSheet> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize the speech recognition service.
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      if (_speechEnabled) {
        _startListening(); // Automatically start listening when the sheet opens
      }
    } catch (e) {
      // print("Speech recognition failed to initialize: $e");
    }
    if (mounted) setState(() {});
  }

  /// Start a listening session and update the UI with live results.
  void _startListening() async {
    if (!_speechEnabled) return;
    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
        });
        // When the user stops speaking, the result is final.
        if (result.finalResult) {
          setState(() => _isListening = false);
          // Wait a moment so the user can see the final text, then close the sheet.
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) {
              Navigator.of(context).pop(_lastWords); // Return the final text
            }
          });
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(
        seconds: 3,
      ), // Automatically stops after 3s of silence
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            color: _isListening ? theme.colorScheme.primary : Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? "Listening..." : "Processing...",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80, // Give the text area a fixed height
            child: Text(
              _lastWords.isEmpty
                  ? "Say your expense, e.g., 'Groceries for 500'"
                  : _lastWords,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    _lastWords.isEmpty
                        ? Colors.grey
                        : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
