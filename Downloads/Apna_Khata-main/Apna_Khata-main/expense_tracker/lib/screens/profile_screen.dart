import 'package:expense_tracker/screens/edit_profile_screen.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/fade_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/widgets/custom_card.dart';
import 'package:expense_tracker/models/user_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  // --- IMPLEMENTATION FOR DIALOGS ---

  Future<void> _showPasswordResetDialog(
    BuildContext context,
    AuthService auth,
  ) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Text(
            'A password reset link will be sent to your email. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await auth.sendPasswordResetEmail();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent!'
                          : 'Could not send email. Please try again.',
                    ),
                    backgroundColor:
                        success
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.error,
                  ),
                );
              },
              child: const Text('Send Email'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    AuthService auth,
  ) async {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('⚠️ Delete Account?'),
          content: const Text(
            'This action is permanent. All your data will be lost. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await auth.deleteUserAccount();
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Could not delete account. Please log out and log back in to continue.',
                      ),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
                // On success, the AuthGate will handle navigation.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Delete My Account'),
            ),
          ],
        );
      },
    );
  }

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
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Sign Out'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                _auth.signOut(); // Perform the sign out action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isGoogleUser =
        user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<UserProfile>(
        stream: _firestore.getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userProfile = snapshot.data!;
          final hasPhoto =
              userProfile.photoURL != null && userProfile.photoURL!.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                elevated: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage:
                          hasPhoto ? NetworkImage(userProfile.photoURL!) : null,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      child:
                          !hasPhoto
                              ? Icon(
                                Icons.person,
                                size: 44,
                                color: theme.colorScheme.primary,
                              )
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userProfile.displayName ?? 'No name set',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(userProfile.email, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.of(context).push(
                      FadePageRoute(
                        page: EditProfileScreen(userProfile: userProfile),
                      ),
                    );
                  },
                ),
              ),
              if (!isGoogleUser) ...[
                const SizedBox(height: 12),
                CustomCard(
                  child: ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text('Change Password'),
                    onTap: () => _showPasswordResetDialog(context, _auth),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              CustomCard(
                child: ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'Sign Out',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  // --- MODIFIED: On tap now calls the new dialog method ---
                  onTap: () => _showSignOutDialog(context),
                ),
              ),
              const SizedBox(height: 12),
              CustomCard(
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Delete Account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onTap: () => _showDeleteAccountDialog(context, _auth),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
