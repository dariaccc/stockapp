import 'package:flutter/material.dart';
import 'login.dart';
import 'main.dart';
import 'user_service.dart';

class Menu extends StatefulWidget {
  final Function(int)? onNavigate;
  final Function(String)? onLocationChanged; // Add callback for location changes

  const Menu({super.key, this.onNavigate, this.onLocationChanged});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String? selectedLanguage;
  String currentLocation = "Germany"; // Default location
  Map<String, dynamic>? currentUser;
  final TextEditingController _controller = TextEditingController();

  final List languages = [
    "German(DE)",
    "English(UK)",
    "French(FR)",
    "Spanish(ES)",
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final user = await UserService.getCurrentUser();
      if (user != null && user['location'] != null) {
        setState(() {
          currentUser = user;
          currentLocation = user['location']['country'] ?? 'Germany';
        });
      }
    } catch (e) {
      print('Error loading current location: $e');
    }
  }

  void _navigateToScreen(int index) {
    // Close the menu
    Navigator.pop(context);

    // Navigate to the specific screen
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
    }
  }

  Future<void> _logout() async {
    try {
      await UserService.logout(); // Clear user session
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      // If logout method doesn't exist, just navigate to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  void _showLocationDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final countries = UserService.getAvailableCountries();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        title: Text(
          'Change Location',
          style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text(
                'Select your country to get localized stock data',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    final isSelected = currentLocation == country['name'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.onSecondary.withValues(alpha: 0.2) : colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? colorScheme.onSecondary : colorScheme.onSecondary.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: isSelected ? Colors.white : colorScheme.onSecondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          country['name']!,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Currency: ${country['currency']}',
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        )
                            : null,
                        onTap: () async {
                          // Show loading indicator
                          Navigator.pop(context);
                          _showLoadingDialog();

                          try {
                            // Update user location in UserService
                            final success = await UserService.updateUserLocation(
                              country: country['name']!,
                              countryCode: country['code']!,
                              city: 'Unknown',
                              currency: country['currency']!,
                            );

                            // Close loading dialog
                            Navigator.pop(context);

                            if (success) {
                              setState(() {
                                currentLocation = country['name']!;
                              });

                              // Notify parent about location change for API updates
                              if (widget.onLocationChanged != null) {
                                widget.onLocationChanged!(country['code']!);
                              }

                              _showMessage('Location updated to ${country['name']}! Stock data refreshing...', isError: false);

                              // Auto-refresh the current screen
                              if (widget.onNavigate != null) {
                                // Refresh current screen by re-navigating to it
                                widget.onNavigate!(0); // Refresh Home by default
                              }
                            } else {
                              _showMessage('Failed to update location. Please try again.', isError: true);
                            }
                          } catch (e) {
                            Navigator.pop(context); // Close loading dialog
                            _showMessage('Error updating location: $e', isError: true);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Updating location and refreshing stock data...',
              style: TextStyle(color: colorScheme.onPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Container(
            //see-through top of the menu
            width: MediaQuery.of(context).size.width,
            height: 200,
            color: const Color(0x801F2937),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: colorScheme.primary, //background colour for the whole footer
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: colorScheme.onPrimary),
                    ),
                  ),

                  //home-button
                  RawMaterialButton(
                    onPressed: () {
                      _navigateToScreen(0); // Navigate to Home (index 0)
                    },
                    fillColor: colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Home", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      _navigateToScreen(1); // Navigate to Radar (index 1)
                    },
                    fillColor: colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Radar", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      _navigateToScreen(2); // Navigate to Pro (index 2)
                    },
                    fillColor: colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Purchase PRO", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: _logout,
                    fillColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: const DefaultTextStyle(
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Log Out", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  RawMaterialButton(
                    onPressed: () {
                      _navigateToScreen(3); // Navigate to Dashboard (index 3)
                    },
                    fillColor: const Color(0xFFFBBD23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      width: 280,
                      height: 38,
                    ),
                    child: const DefaultTextStyle(
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Dashboard", textAlign: TextAlign.center),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 280,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF1F2937),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: DropdownButton<String>(
                            value: selectedLanguage,
                            hint: const Text(
                              "Language",
                              style: TextStyle(color: Colors.white),
                            ),
                            dropdownColor: const Color(0xFF1F2937),
                            items: languages.map((language) {
                              return DropdownMenuItem<String>(
                                value: language,
                                child: Text(
                                  language,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value;
                              });
                            },
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Enhanced Location Button with Tap Functionality
                  GestureDetector(
                    onTap: _showLocationDialog,
                    child: Container(
                      width: 280,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: colorScheme.onSecondary,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.pin_drop, color: Colors.white, size: 20),
                            Expanded(
                              child: Text(
                                currentLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.edit, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: DefaultTextStyle(
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 8),
                      child: const Text(
                        "VANTYX is not a registered broker-dealer or "
                            "investment advisor. Trading involves risk and may "
                            "result in financial loss. Market data is provided for "
                            "informational purposes only and is not intended for trading"
                            " or investment advice. Past performance does not guarantee "
                            "future results. Always do your own research before making "
                            "financial decisions..",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Image(
                          height: 35,
                          image: AssetImage('assets/images/logo-test.png'),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => MyApp.of(context).changeTheme(ThemeMode.light),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary,
                              ),
                              child: Text(
                                "Light",
                                style: TextStyle(color: colorScheme.onTertiary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => MyApp.of(context).changeTheme(ThemeMode.dark),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary,
                              ),
                              child: Text(
                                'Dark',
                                style: TextStyle(color: colorScheme.tertiary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}