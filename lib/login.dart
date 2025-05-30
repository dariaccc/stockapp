import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'navbar.dart';
import 'registeration.dart';
import 'user_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _customerIdController = TextEditingController();
  String _pinCode = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  // Check if user is already logged in
  Future<void> _checkCurrentUser() async {
    final user = await UserService.getCurrentUser();
    if (user != null && mounted) {
      // User is already logged in, navigate to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // VANTYX Logo
            Text(
              'VANTYX',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),

            // Login Container
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: colorScheme.secondary,
              ),
              width: 300,
              child: Column(
                children: [
                  Text(
                    "LOGIN",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Customer ID input field
                  Text(
                    "Customer ID",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customerIdController,
                    cursorColor: colorScheme.onSecondary,
                    style: TextStyle(color: colorScheme.onPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: colorScheme.primary,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PIN input field
                  Text(
                    "PIN",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    cursorColor: colorScheme.onSecondary,
                    textStyle: TextStyle(color: colorScheme.onPrimary),
                    enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: colorScheme.onSecondary,
                      inactiveColor: colorScheme.primary,
                      selectedColor: colorScheme.onSecondary,
                      activeFillColor: colorScheme.primary,
                      inactiveFillColor: colorScheme.primary,
                      selectedFillColor: colorScheme.primary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _pinCode = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Login button
                  RawMaterialButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    fillColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 120,
                      height: 40,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "Login",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Register link
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Registration()),
                      );
                    },
                    child: Text(
                      "NO ACCOUNT? REGISTER NOW",
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Administrator Login
                  GestureDetector(
                    onTap: _showAdminDialog,
                    child: Text(
                      "Administrator Login",
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validate input
    if (_customerIdController.text.trim().isEmpty || _pinCode.length != 6) {
      _showMessage('Please enter Customer ID and 6-digit PIN', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserService.loginUser(
        customerId: _customerIdController.text.trim(),
        pin: _pinCode,
      );

      if (result['success']) {
        _showMessage(result['message'], isError: false);

        // Navigate to main app after short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Navigation()),
          );
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      _showMessage('Login failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAdminDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text('Admin Login', style: TextStyle(color: colorScheme.onPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('View all registered users:', style: TextStyle(color: colorScheme.onSecondary)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _showAllUsers();
              },
              style: ElevatedButton.styleFrom(backgroundColor: colorScheme.onSecondary),
              child: const Text('View Users', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllUsers() async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final users = await UserService.getAllUsers();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text('Registered Users (${users.length})', style: TextStyle(color: colorScheme.onPrimary)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: users.isEmpty
              ? Center(
            child: Text('No users registered yet', style: TextStyle(color: colorScheme.onSecondary)),
          )
              : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['fullName'] ?? 'Unknown',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${user['customerId']}',
                      style: TextStyle(color: colorScheme.onSecondary, fontSize: 12),
                    ),
                    Text(
                      'Email: ${user['emailId']}',
                      style: TextStyle(color: colorScheme.onSecondary, fontSize: 12),
                    ),
                    Text(
                      'Location: ${user['location']?['country'] ?? 'Unknown'}',
                      style: TextStyle(color: colorScheme.onSecondary, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }
}