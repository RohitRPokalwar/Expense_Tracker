import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/widgets/custom_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _error = '';
  bool _isLoading = false;

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final user = await _auth.registerWithEmailAndPassword(_email, _password);
      if (user == null && mounted) {
        setState(() {
          _error = 'Registration failed. The email might already be in use.';
          _isLoading = false;
        });
      } else if (user != null && mounted) {
        // Pop the RegisterScreen so AuthGate can show the MainAppShell
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _auth.signInWithGoogle();
    if (user == null && mounted) {
      setState(() {
        _error = 'Google Sign-In failed. Please try again.';
        _isLoading = false;
      });
    } else if (user != null && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This build method is correct and does not need changes.
    // Full code provided for completeness.
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Text('Create Account', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Let’s get started with a fresh account',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                CustomCard(
                  elevated: true,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter an email'
                                      : null,
                          onChanged: (val) => setState(() => _email = val),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator:
                              (val) =>
                                  val != null && val.length < 6
                                      ? 'Password must be 6+ characters'
                                      : null,
                          onChanged: (val) => setState(() => _password = val),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const SizedBox(
                              height: 48,
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleRegistration,
                                child: const Text('Register'),
                              ),
                            ),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('OR'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.g_mobiledata_rounded),
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            label: const Text('Sign up with Google'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
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
