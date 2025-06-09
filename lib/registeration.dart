import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'navbar.dart';
import 'user_service.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalCardController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardDetailsController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String _pinCode = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Registration',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // VANTYX Logo
              Text(
                'VANTYX',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Registration Form Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text(
                      'REGISTER',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Full Name
                    _buildTextField('Full Name', _fullNameController, colorScheme),
                    const SizedBox(height: 15),

                    // Date of Birth
                    _buildTextField('Date of Birth', _dobController, colorScheme, isDateField: true),
                    const SizedBox(height: 15),

                    // National Card Number
                    _buildTextField('National Card Number', _nationalCardController, colorScheme),
                    const SizedBox(height: 15),

                    // Phone Number
                    _buildTextField('Phone Number', _phoneController, colorScheme, inputType: TextInputType.phone),
                    const SizedBox(height: 15),

                    // Email ID
                    _buildTextField('Email ID', _emailController, colorScheme, inputType: TextInputType.emailAddress),
                    const SizedBox(height: 15),

                    // Card Details
                    _buildTextField('Card Details', _cardDetailsController, colorScheme),
                    const SizedBox(height: 15),

                    // Expiry and CVV Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('Expiry', _expiryController, colorScheme, hintText: 'MM/YY'),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField('CVV', _cvvController, colorScheme, inputType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // PIN Section
                    Text(
                      'PIN',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // PIN Input
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
                        borderWidth: 1,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _pinCode = value;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'REGISTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Administrator Login
                    TextButton(
                      onPressed: () {
                        _showAdminDialog();
                      },
                      child: Text(
                        'Administrator Login',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      ColorScheme colorScheme, {
        TextInputType inputType = TextInputType.text,
        bool isDateField = false,
        String? hintText,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: TextStyle(color: colorScheme.onPrimary),
          maxLength: label == 'Expiry' ? 5 : null, // Limit expiry to MM/YY format
          decoration: InputDecoration(
            hintText: _getHintText(label, hintText),
            hintStyle: TextStyle(color: colorScheme.onSecondary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.onSecondary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            counterText: '', // Hide character counter
          ),
          onTap: isDateField ? () => _selectDate(context, controller) : null,
          readOnly: isDateField,
          onChanged: (value) {
            if (label == 'Expiry') {
              _formatExpiryDate(value, controller);
            } else if (inputType == TextInputType.emailAddress) {
              _validateEmailRealTime(value);
            }
          },
        ),
        // Show validation hints for specific fields
        if (_shouldShowValidationHint(label, controller.text))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _getValidationHint(label, controller.text),
              style: TextStyle(
                color: _isFieldValid(label, controller.text) ? Colors.green : Colors.orange,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  String? _getHintText(String label, String? providedHint) {
    if (providedHint != null) return providedHint;

    switch (label) {
      case 'Full Name':
        return 'Enter first and last name';
      case 'Date of Birth':
        return 'DD/MM/YYYY';
      case 'National Card Number':
        return 'Enter your ID card number';
      case 'Phone Number':
        return '+1234567890 or 1234567890';
      case 'Email ID':
        return 'example@email.com';
      case 'Card Details':
        return '1234 5678 9012 3456';
      case 'Expiry':
        return 'MM/YY';
      case 'CVV':
        return '123 or 1234';
      default:
        return null;
    }
  }

  bool _shouldShowValidationHint(String label, String value) {
    if (value.isEmpty) return false;

    switch (label) {
      case 'Email ID':
      case 'Phone Number':
      case 'Card Details':
      case 'Expiry':
      case 'CVV':
        return true;
      default:
        return false;
    }
  }

  String _getValidationHint(String label, String value) {
    switch (label) {
      case 'Email ID':
        return _isValidEmail(value) ? '✓ Valid email format' : '✗ Invalid email format';
      case 'Phone Number':
        return _isValidPhoneNumber(value) ? '✓ Valid phone number' : '✗ Invalid phone number';
      case 'Card Details':
        if (value.isEmpty) return '';
        final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length < 13) {
          return '✗ Need ${13 - digitsOnly.length} more digits (${digitsOnly.length}/13-19)';
        } else if (digitsOnly.length > 19) {
          return '✗ Too many digits (${digitsOnly.length}/19 max)';
        } else {
          return '✓ Valid length (${digitsOnly.length} digits)';
        }
      case 'Expiry':
        return _isValidExpiryDate(value) ? '✓ Valid expiry date' : '✗ Invalid or expired date';
      case 'CVV':
        return _isValidCVV(value) ? '✓ Valid CVV' : '✗ CVV must be 3-4 digits';
      default:
        return '';
    }
  }

  bool _isFieldValid(String label, String value) {
    switch (label) {
      case 'Email ID':
        return _isValidEmail(value);
      case 'Phone Number':
        return _isValidPhoneNumber(value);
      case 'Card Details':
        return _isValidCardNumber(value);
      case 'Expiry':
        return _isValidExpiryDate(value);
      case 'CVV':
        return _isValidCVV(value);
      default:
        return true;
    }
  }

  void _validateEmailRealTime(String value) {
    // This will trigger the hint to update in real-time
    setState(() {});
  }

  void _formatExpiryDate(String value, TextEditingController controller) {
    // Remove any non-digit characters
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 4 digits maximum
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      formatted = digitsOnly.substring(0, digitsOnly.length > 2 ? 2 : digitsOnly.length);
      if (digitsOnly.length > 2) {
        formatted += '/${digitsOnly.substring(2)}';
      }
    }

    // Auto-add slash after 2 digits
    if (digitsOnly.length == 2 && !value.contains('/')) {
      formatted += '/';
    }

    // Update controller only if the formatted value is different
    if (controller.text != formatted) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Trigger validation hint update
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<void> _handleRegistration() async {
    // Comprehensive validation
    final validationResult = _validateFormData();
    if (!validationResult['isValid']) {
      _showMessage(validationResult['message'], isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting registration process...');
      final result = await UserService.registerUser(
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        nationalCardNumber: _nationalCardController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        emailId: _emailController.text.trim(),
        cardDetails: _cardDetailsController.text.trim(),
        expiry: _expiryController.text.trim(),
        cvv: _cvvController.text.trim(),
        pin: _pinCode,
      );

      print('Registration result: $result');

      if (result['success']) {
        // Automatically log in the user after successful registration
        print('Attempting auto-login with Customer ID: ${result['customerId']}');

        try {
          final loginResult = await UserService.loginUser(
            customerId: result['customerId'],
            pin: _pinCode,
          );

          print('Auto-login result: $loginResult');

          if (loginResult['success']) {
            print('Auto-login successful, showing success dialog');
            // Show success message with Customer ID
            _showCustomerIdDialog(result['customerId'], result['message']);
          } else {
            print('Auto-login failed: ${loginResult['message']}');
            // Registration successful but auto-login failed
            _showMessage('Registration successful! Please login with your Customer ID: ${result['customerId']}', isError: false);
            // Navigate to main app anyway
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Navigation()),
            );
          }
        } catch (loginError) {
          print('Auto-login error: $loginError');
          // If UserService.loginUser doesn't exist, just show success and navigate
          _showCustomerIdDialog(result['customerId'], result['message']);
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      print('Registration error: $e');
      _showMessage('Registration failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _validateFormData() {
    // Check if all fields are filled
    if (_fullNameController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter your full name'};
    }

    if (_dobController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please select your date of birth'};
    }

    if (_nationalCardController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter your national card number'};
    }

    if (_phoneController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter your phone number'};
    }

    if (_emailController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter your email address'};
    }

    if (_cardDetailsController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter your card details'};
    }

    if (_expiryController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter card expiry date'};
    }

    if (_cvvController.text.trim().isEmpty) {
      return {'isValid': false, 'message': 'Please enter CVV'};
    }

    if (_pinCode.length != 6) {
      return {'isValid': false, 'message': 'Please enter a 6-digit PIN'};
    }

    // Validate full name (at least 2 words)
    final nameParts = _fullNameController.text.trim().split(' ');
    if (nameParts.length < 2 || nameParts.any((part) => part.isEmpty)) {
      return {'isValid': false, 'message': 'Please enter your full name (first and last name)'};
    }

    // Validate email format
    if (!_isValidEmail(_emailController.text.trim())) {
      return {'isValid': false, 'message': 'Please enter a valid email address'};
    }

    // Validate phone number
    if (!_isValidPhoneNumber(_phoneController.text.trim())) {
      return {'isValid': false, 'message': 'Please enter a valid phone number (10-15 digits)'};
    }

    // Validate date of birth
    if (!_isValidDateOfBirth(_dobController.text.trim())) {
      return {'isValid': false, 'message': 'Please enter a valid date of birth (must be 18+ years old)'};
    }

    // Validate national card number
    if (!_isValidNationalCard(_nationalCardController.text.trim())) {
      return {'isValid': false, 'message': 'National card number must be 8-20 characters'};
    }

    // Validate card details (basic card number format)
    if (!_isValidCardNumber(_cardDetailsController.text.trim())) {
      return {'isValid': false, 'message': 'Please enter a valid card number (13-19 digits)'};
    }

    // Validate expiry date
    if (!_isValidExpiryDate(_expiryController.text.trim())) {
      return {'isValid': false, 'message': 'Please enter a valid expiry date (MM/YY) in the future'};
    }

    // Validate CVV
    if (!_isValidCVV(_cvvController.text.trim())) {
      return {'isValid': false, 'message': 'CVV must be 3 or 4 digits'};
    }

    // Validate PIN (6 digits, not all same)
    if (!_isValidPIN(_pinCode)) {
      return {'isValid': false, 'message': 'PIN must be 6 different digits (avoid 111111, 123456, etc.)'};
    }

    return {'isValid': true, 'message': 'All validations passed'};
  }

  // FIXED: Email validation with proper regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove any non-digit characters for validation
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  bool _isValidDateOfBirth(String dob) {
    try {
      // Parse DD/MM/YYYY format
      final parts = dob.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - birthDate.year -
          (now.month < birthDate.month ||
              (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);

      // Must be at least 18 years old and not in the future
      return age >= 18 && birthDate.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  bool _isValidNationalCard(String cardNumber) {
    // Basic validation: 8-20 alphanumeric characters
    final cleanCard = cardNumber.replaceAll(RegExp(r'[^\w]'), '');
    return cleanCard.length >= 8 && cleanCard.length <= 20;
  }

  bool _isValidCardNumber(String cardNumber) {
    // Remove all non-digit characters (spaces, dashes, etc.)
    final digitsOnly = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if we have any digits
    if (digitsOnly.isEmpty) {
      return false;
    }

    // Simple length check: 13-19 digits
    return digitsOnly.length >= 13 && digitsOnly.length <= 19;
  }

  bool _isValidExpiryDate(String expiry) {
    try {
      // Check if format is MM/YY (5 characters total)
      if (expiry.length != 5 || !expiry.contains('/')) return false;

      // Parse MM/YY format
      final parts = expiry.split('/');
      if (parts.length != 2) return false;

      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}'); // Convert YY to 20YY

      // Check valid month (01-12)
      if (month < 1 || month > 12) return false;

      // Check if date is in the future
      final now = DateTime.now();
      final expiryDate = DateTime(year, month + 1, 0); // Last day of expiry month

      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  bool _isValidCVV(String cvv) {
    // CVV should be 3 or 4 digits
    final digitsOnly = cvv.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length == 3 || digitsOnly.length == 4;
  }

  // FIXED: PIN validation with proper regex
  bool _isValidPIN(String pin) {
    // Check if PIN is 6 digits
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      return false;
    }

    // Check for common weak PINs
    final weakPins = [
      '111111', '222222', '333333', '444444', '555555', '666666', '777777', '888888', '999999', '000000',
      '123456', '654321', '012345', '543210', '098765', '567890',
      '121212', '123123', '456456', '789789',
    ];

    if (weakPins.contains(pin)) {
      return false;
    }

    // Check if all digits are the same
    if (pin.split('').toSet().length == 1) {
      return false;
    }

    return true;
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

  void _showCustomerIdDialog(String customerId, String message) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Registration Successful!',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to VANTYX!',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Customer ID:',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customerId,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '⚠️ Important: Save this Customer ID!',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You need it to login to your account.',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Navigation()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue to App',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text('Admin Access', style: TextStyle(color: colorScheme.onPrimary)),
        content: Text('Admin functionality coming soon!', style: TextStyle(color: colorScheme.onSecondary)),
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
    _fullNameController.dispose();
    _dobController.dispose();
    _nationalCardController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cardDetailsController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}