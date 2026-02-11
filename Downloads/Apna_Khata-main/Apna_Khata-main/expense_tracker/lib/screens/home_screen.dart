import 'dart:async';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/user_profile_model.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/screens/expenses_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'package:expense_tracker/services/ai_service.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/balance_card.dart';
import 'package:expense_tracker/widgets/fade_page_route.dart';
import 'package:expense_tracker/widgets/transaction_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _authService = AuthService();
  final _aiService = AiService();
  final _firestoreService = FirestoreService();

  // --- Speech-to-Text State Variables ---
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize the speech recognition service once.
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      // debugPrint("Speech recognition failed to initialize: $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  // --- THIS IS THE NEW, CORRECTED, AND COMPATIBLE VOICE LOGIC ---
  Future<void> _handleVoiceInput() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available.')),
      );
      return;
    }

    final completer = Completer<String?>();
    String recognizedWords = "";

    // Start listening right away.
    _speechToText.listen(
      onResult: (result) {
        // This is called continuously. We update a variable with the latest text.
        recognizedWords = result.recognizedWords;

        // When the speech engine is confident the user is done, it sets this flag.
        if (result.finalResult) {
          // If our completer hasn't been finished yet, finish it with the final text.
          if (!completer.isCompleted) {
            completer.complete(recognizedWords);
          }
        }
      },
      // These help the engine know when to stop automatically.
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );

    // Show the dialog. It will display the live recognized words.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ListeningDialog(
          speechToText: _speechToText,
          // This future will complete when the speech is final, closing the dialog.
          resultFuture: completer.future,
          onCancel: () {
            // If the user cancels, stop listening and complete with null.
            _speechToText.stop();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );

    // After the dialog closes, get the final result from the completer.
    final finalResult = await completer.future;

    if (finalResult != null && finalResult.isNotEmpty) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(FadePageRoute(page: AddExpenseScreen(initialText: finalResult)));
    }
  }
  // --- END OF NEW LOGIC ---

  Future<void> _importPdf() async {
    try {
      // Pick a PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || !mounted) return;

      final path = result.files.single.path;
      if (path == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Uploading and analyzing PDF...'),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );

      // Call the AI service
      final processedData = await _aiService.analyzePdfReceipt(path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (processedData != null) {
        // Navigate to add expense screen with data
        Navigator.of(context).push(
          FadePageRoute(page: AddExpenseScreen(initialData: processedData)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not process PDF. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing PDF: $e')));
      }
    }
  }

  Future<void> _scanReceipt() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Uploading and analyzing receipt...'),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
    final result = await _aiService.analyzeReceiptImage(image.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (result != null) {
      Navigator.of(
        context,
      ).push(FadePageRoute(page: AddExpenseScreen(initialData: result)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not process your request. Please try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _greetingName() {
    final user = _auth.currentUser;
    // Use display name from Firestore profile as the primary source
    return user?.displayName ?? 'Friend'; // Fallback
  }

  double _monthlyTotal(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) {
          final d = e.timestamp.toDate();
          return d.year == now.year && d.month == now.month;
        })
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  double _lastMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();
    // DateTime constructor handles month overflow/underflow (e.g., month 0 is Dec prev year)
    final lastMonth = DateTime(now.year, now.month - 1);
    return expenses
        .where((e) {
          final d = e.timestamp.toDate();
          return d.year == lastMonth.year && d.month == lastMonth.month;
        })
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  // Dialog for signing out
  Future<void> _showSignOutDialog(BuildContext context) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out?'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Sign Out'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _authService.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return StreamBuilder<UserProfile>(
      stream: _firestoreService.getUserProfile(),
      builder: (context, snapshot) {
        final displayName = snapshot.data?.displayName ?? _greetingName();
        final photoURL = snapshot.data?.photoURL;
        final avatarChild =
            photoURL != null
                ? CircleAvatar(
                  backgroundImage: NetworkImage(photoURL),
                  radius: 18,
                )
                : Icon(Icons.person, color: tokens.iconColor);

        return Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(FadePageRoute(page: const ProfileScreen()));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: tokens.iconColor.withValues(alpha: 0.12),
                child: avatarChild,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, $displayName!', style: theme.textTheme.titleLarge),
                  Text(
                    'Manage your expenses smartly',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.chat_bubble_outline_rounded, color: tokens.iconColor),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'signOut') {
                  _showSignOutDialog(context);
                }
              },
              icon: Icon(Icons.settings_outlined, color: tokens.iconColor),
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'signOut',
                      child: Text('Sign Out'),
                    ),
                  ],
            ),
          ],
        );
      },
    );
  }

  Widget _actionsRow(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    Widget btn(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow:
                      Theme.of(context).extension<AppShadows>()!.cardShadow,
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(icon, color: tokens.iconColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Row(
      children: [
        btn(
          Icons.payment,
          'Expenses',
          () => Navigator.of(
            context,
          ).push(FadePageRoute(page: const ExpensesScreen())),
        ),
        const SizedBox(width: 12),
        btn(
          Icons.analytics,
          'Analysis',
          () => Navigator.of(
            context,
          ).push(FadePageRoute(page: const ReportsScreen())),
        ),
        const SizedBox(width: 12),
        btn(Icons.download_rounded, 'Reports', () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Reports coming soon'),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          );
        }),
      ],
    );
  }

  Widget _inputMethodCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final theme = Theme.of(context);
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: tokens.primaryAccent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: Theme.of(context).extension<AppShadows>()!.cardShadow,
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tokens.primaryText, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: tokens.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF7F4), Color(0xFFF7F9F9)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Expense>>(
            stream: _firestoreService.getExpensesStream(),
            builder: (context, snapshot) {
              final expenses = snapshot.data ?? [];
              final monthly = _monthlyTotal(expenses);
              final lastMonth = _lastMonthTotal(expenses);
              final delta = monthly - lastMonth;
              final latest = expenses.take(3).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow:
                            Theme.of(
                              context,
                            ).extension<AppShadows>()!.cardShadow,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          BalanceCard(
                            currency: 'INR',
                            amount: monthly,
                            subtitle: 'This month',
                            delta: delta,
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _actionsRow(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Transactions',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.of(context).push(
                                FadePageRoute(page: const ExpensesScreen()),
                              ),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (latest.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No recent transactions.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      Column(
                        children: List.generate(
                          latest.length,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TransactionTile(
                              expense: latest[i],
                              index: i,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Add Expense By',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // --- The Voice Entry button now calls the correct, robust handler ---
                        _inputMethodCard(
                          icon: Icons.mic,
                          label: 'Voice Entry',
                          onTap: _handleVoiceInput,
                        ),
                        // ------------------------------------
                        const SizedBox(width: 12),
                        _inputMethodCard(
                          icon: Icons.picture_as_pdf_outlined,
                          label: 'Import PDF',
                          onTap: _importPdf,
                        ),
                        const SizedBox(width: 12),
                        _inputMethodCard(
                          icon: Icons.post_add_outlined,
                          label: 'Add Manually',
                          onTap:
                              () => Navigator.of(context).push(
                                FadePageRoute(page: const AddExpenseScreen()),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _scanReceipt,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Scan Receipt'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- NEW HELPER WIDGET FOR THE DIALOG ---
// It's cleaner to put the dialog UI in its own widget.
class ListeningDialog extends StatefulWidget {
  final SpeechToText speechToText;
  final VoidCallback onCancel;
  final Future<String?> resultFuture;

  const ListeningDialog({
    super.key,
    required this.speechToText,
    required this.onCancel,
    required this.resultFuture,
  });

  @override
  State<ListeningDialog> createState() => _ListeningDialogState();
}

class _ListeningDialogState extends State<ListeningDialog> {
  String _currentWords = "";

  @override
  void initState() {
    super.initState();
    // Listen to the speech engine's notifications to update the UI
    widget.speechToText.statusListener =
        (status) => setState(() {}); // Redraw on status change
    widget.speechToText.errorListener =
        (error) => setState(() {}); // Redraw on error

    // Auto-close dialog when future completes
    widget.resultFuture.whenComplete(() {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We get the live text directly from the speech engine's last result
    _currentWords = widget.speechToText.lastRecognizedWords;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Listening...'),
        ],
      ),
      content: Text(
        _currentWords.isEmpty
            ? "Say your expense, e.g., 'Groceries for 500'"
            : _currentWords,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color:
              _currentWords.isEmpty
                  ? Colors.grey.shade600
                  : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
      ],
    );
  }
}
