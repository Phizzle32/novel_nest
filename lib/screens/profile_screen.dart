import 'package:flutter/material.dart';
import 'package:novel_nest/screens/login_screen.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:novel_nest/widgets/app_background.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final List<String> _genres = [];
  final List<String> _preferredGenres = [];
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGenreError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();

    final user = await authService.getCurrentUser();
    final genres = await firestoreService.getGenres();

    setState(() {
      _displayNameController.text = user?.displayName ?? '';
      _preferredGenres.addAll(user?.preferredGenres ?? []);
      _genres.addAll(genres);
    });
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (_newPasswordController.text.isNotEmpty &&
        (value == null || value.isEmpty)) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? _newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 6) {
      return 'New password must be at least 6 characters';
    }
    if (value == _passwordController.text) {
      return 'New password cannot be the same as old password';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (_newPasswordController.text.isNotEmpty) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your new password';
      }
      if (value != _newPasswordController.text) {
        return 'Passwords do not match';
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isGenreError = _preferredGenres.isEmpty;
    });
    if ((_formKey.currentState?.validate() ?? false) && !_isGenreError) {
      try {
        final authService = context.read<AuthService>();
        final firestoreService = context.read<FirestoreService>();
        final user = await authService.getCurrentUser();

        if (user == null) {
          return;
        }

        if (_passwordController.text.isNotEmpty) {
          try {
            await authService.changePassword(
              _passwordController.text,
              _newPasswordController.text,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid credentials')),
              );
            }
            return;
          }
        }

        await firestoreService.updateUser(
          user: user,
          displayName: _displayNameController.text.trim(),
          preferredGenres: _preferredGenres,
        );

        _passwordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile')),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete your account?'),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const NovelNestAppBar(),
      drawer: const NovelNestDrawer(),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey),
                  color: const Color(0xFFF5F5F5),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Change Profile Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder(),
                          counterText: '',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        maxLength: 20,
                        validator: _nameValidator,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Preferred Genres',
                          border: const OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          errorText: _isGenreError
                              ? 'Please select at least one genre'
                              : null,
                        ),
                        items: _genres.map((String genre) {
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              !_preferredGenres.contains(newValue)) {
                            setState(() {
                              _preferredGenres.add(newValue);
                            });
                          }
                        },
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _preferredGenres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            onDeleted: () {
                              setState(() {
                                _preferredGenres.remove(genre);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        obscureText: true,
                        validator: _passwordValidator,
                      ),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        obscureText: true,
                        validator: _newPasswordValidator,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        obscureText: true,
                        validator: _confirmPasswordValidator,
                      ),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save Changes'),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.red),
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                            ),
                            onPressed: _deleteAccount,
                            child: const Text('Delete'),
                          ),
                          ElevatedButton(
                            onPressed: _logout,
                            child: const Text('Log out'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
