import 'package:flutter/material.dart';

class Pro extends StatefulWidget {
  const Pro({super.key});

  @override
  State<Pro> createState() => _ProState();
}

class _ProState extends State<Pro> {
  List<Map<String, dynamic>> features = [
    {'title': 'Live Market Search', 'basic': false, 'goals': true, 'luxe': true},
    {'title': 'Stock Notifications', 'basic': false, 'goals': true, 'luxe': true},
    {'title': 'Priority Market Insights', 'basic': false, 'goals': false, 'luxe': true},
    {'title': 'Advanced Analytics', 'basic': false, 'goals': false, 'luxe': true},
    {'title': 'Unlimited Account Access', 'basic': false, 'goals': false, 'luxe': true},
    {'title': 'Portfolio Investment Reports', 'basic': false, 'goals': false, 'luxe': true},
  ];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Pro Purchase',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // VANTYX LUXE Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'VANTYX LUXE',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Tailored for investors who demand more, VANTYX LUXE offers extra tools, deeper insights, and faster access. Unlock premium features that put you ahead in the competitive world of investing with best-in-class investments.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Feature comparison table header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'EXTRA Features with LUXE',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Plan',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Goals',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'LUXE',
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Feature rows
                    ...features.map((feature) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              feature['title'],
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              feature['basic'] ? Icons.check_circle : Icons.cancel,
                              color: feature['basic'] ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              feature['goals'] ? Icons.check_circle : Icons.cancel,
                              color: feature['goals'] ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              feature['luxe'] ? Icons.check_circle : Icons.cancel,
                              color: feature['luxe'] ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 25),

                    // Bottom navigation icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.home, color: colorScheme.onSecondary, size: 20),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.radar, color: colorScheme.onSecondary, size: 20),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.star, color: colorScheme.onSecondary, size: 20),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.person, color: colorScheme.onSecondary, size: 20),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.onSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.menu, color: colorScheme.onSecondary, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Exclusive Pro Access button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.lock, color: colorScheme.onSecondary, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Exclusive Pro Access',
                            style: TextStyle(
                              color: colorScheme.onSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Because true success isn\'t left to chance – it\'s built with some new tools, detailed insights, and faster access. VANTYX LUXE Premium subscription gives you the edge to invest beyond limits while using advanced tools to easily understand market data and turn insights into reality.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Buy button
                    ElevatedButton(
                      onPressed: () {
                        _showPurchaseDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'BUY VANTYX LUXE NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  void _showPurchaseDialog() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.secondary,
          title: Text(
            'Purchase VANTYX LUXE',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose your subscription plan:',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              const SizedBox(height: 20),

              // Monthly Plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly Plan',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$9.99/month',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Yearly Plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.onSecondary),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yearly Plan',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'SAVE 20%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\$99.99/year',
                      style: TextStyle(
                        color: colorScheme.onSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colorScheme.onPrimary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Purchase successful! Welcome to VANTYX LUXE!'),
                    backgroundColor: colorScheme.onSecondary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSecondary,
              ),
              child: const Text('Purchase', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}