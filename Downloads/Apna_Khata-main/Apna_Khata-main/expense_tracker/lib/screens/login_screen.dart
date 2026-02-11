import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/screens/register_screen.dart';
import 'package:expense_tracker/widgets/custom_card.dart';
import 'package:expense_tracker/widgets/fade_page_route.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _error = '';
  bool _isLoading = false;

  // Handler for Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _auth.signInWithGoogle();
    if (user == null && mounted) {
      setState(() {
        _error = 'Google Sign-In failed. Please try again.';
        _isLoading = false;
      });
    }
    // If successful, the AuthGate will handle navigation.
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Text('Welcome Back', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue tracking your finances',
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
                                      ? 'Enter a password 6+ chars long'
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
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isLoading = true);
                                    final result = await _auth.signIn(
                                      _email,
                                      _password,
                                    );
                                    if (result == null && mounted) {
                                      setState(() {
                                        _error =
                                            'Could not sign in with those credentials';
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                                child: const Text('Sign In'),
                              ),
                            ),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error,
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
                            label: const Text('Sign in with Google'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).push(FadePageRoute(page: const RegisterScreen()));
                          },
                          child: const Text('Don\'t have an account? Register'),
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
