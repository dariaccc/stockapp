import 'package:flutter/material.dart';
import 'stockpage.dart';
import 'api_service.dart';

class Home extends StatefulWidget {
  final String locationCode;

  const Home({super.key, this.locationCode = 'DE'});

  @override
  State<Home> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  Map<String, dynamic>? lastViewedStock;
  List<Map<String, dynamic>> topSectors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStockData();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when location changes
    if (oldWidget.locationCode != widget.locationCode) {
      loadStockData();
    }
  }

  Future<void> loadStockData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get location-based data first
      final locationData = await ApiService.getLocationBasedData();

      // Get different stock based on location
      String primaryStock = _getPrimaryStockForLocation(widget.locationCode);
      final stockQuote = await ApiService.getStockQuote(primaryStock);

      if (stockQuote != null) {
        final isPositive = stockQuote['change'] >= 0;
        setState(() {
          lastViewedStock = {
            'symbol': stockQuote['symbol'],
            'name': _getStockName(stockQuote['symbol']),
            'price': '\$${stockQuote['price'].toStringAsFixed(2)}',
            'change': '${isPositive ? '+' : ''}${stockQuote['changePercent']}%',
            'changeColor': isPositive ? Colors.green : Colors.red,
          };
        });
      } else {
        // Fallback data based on location
        final fallbackData = _getFallbackDataForLocation(widget.locationCode);
        setState(() {
          lastViewedStock = fallbackData;
        });
      }

      // Get recommended stocks based on location
      List<String> recommendedStocks = _getRecommendedStocksForLocation(widget.locationCode);

      // Get multiple stock data to calculate sector performance
      final stocksData = await ApiService.getMultipleStocks(recommendedStocks.take(10).toList());

      // Calculate sector data based on location and actual stock performance
      setState(() {
        topSectors = _getSectorsForLocation(widget.locationCode, stocksData);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading stock data: $e');
      // Set fallback data based on location
      setState(() {
        lastViewedStock = _getFallbackDataForLocation(widget.locationCode);
        topSectors = _getSectorsForLocation(widget.locationCode, []);
        isLoading = false;
      });
    }
  }

  String _getPrimaryStockForLocation(String locationCode) {
    switch (locationCode) {
      case 'US': return 'AAPL';
      case 'DE': return 'SAP';  // German SAP stock
      case 'GB': return 'AZN';  // UK AstraZeneca
      case 'JP': return '7203'; // Toyota
      case 'FR': return 'ASML'; // ASML (Netherlands/Europe)
      case 'CA': return 'SHOP'; // Shopify (Canadian)
      default: return 'AAPL';
    }
  }

  String _getStockName(String symbol) {
    switch (symbol) {
      case 'AAPL': return 'Apple Inc.';
      case 'SAP': return 'SAP SE';
      case 'AZN': return 'AstraZeneca PLC';
      case '7203': return 'Toyota Motor';
      case 'ASML': return 'ASML Holding';
      case 'SHOP': return 'Shopify Inc.';
      default: return 'Unknown Company';
    }
  }

  Map<String, dynamic> _getFallbackDataForLocation(String locationCode) {
    switch (locationCode) {
      case 'US':
        return {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'price': '\$150.00',
          'change': '+2.5%',
          'changeColor': Colors.green,
        };
      case 'DE':
        return {
          'symbol': 'SAP',
          'name': 'SAP SE',
          'price': '€142.30',
          'change': '+1.8%',
          'changeColor': Colors.green,
        };
      case 'GB':
        return {
          'symbol': 'AZN',
          'name': 'AstraZeneca PLC',
          'price': '£122.60',
          'change': '+2.5%',
          'changeColor': Colors.green,
        };
      case 'JP':
        return {
          'symbol': '7203',
          'name': 'Toyota Motor',
          'price': '¥2,845',
          'change': '+0.5%',
          'changeColor': Colors.green,
        };
      default:
        return {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'price': '\$150.00',
          'change': '+2.5%',
          'changeColor': Colors.green,
        };
    }
  }

  List<String> _getRecommendedStocksForLocation(String locationCode) {
    switch (locationCode) {
      case 'US':
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 'META', 'NVDA'];
      case 'DE':
        return ['SAP', 'SIE', 'BMW', 'BAS', 'ALV', 'DTE', 'DBK'];
      case 'GB':
        return ['AZN', 'SHEL', 'BP', 'ULVR', 'GSK', 'LSEG', 'BT'];
      case 'JP':
        return ['7203', '6758', '9984', '6861', '8306', '9983', '4689'];
      case 'FR':
        return ['ASML', 'OR', 'SAF', 'AIR', 'BNP', 'TTE', 'MC'];
      default:
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'];
    }
  }

  List<Map<String, dynamic>> _getSectorsForLocation(String locationCode, List<dynamic> stocksData) {
    switch (locationCode) {
      case 'US':
        return [
          {'name': 'Technology', 'change': stocksData.isNotEmpty ? '${stocksData[0]['changePercent']}%' : '+2.5%', 'color': Colors.green},
          {'name': 'Healthcare', 'change': '+1.8%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Consumer', 'change': '+0.8%', 'color': Colors.green},
          {'name': 'Energy', 'change': '-0.3%', 'color': Colors.red},
          {'name': 'Utilities', 'change': '+0.5%', 'color': Colors.green},
        ];
      case 'DE':
        return [
          {'name': 'Automotive', 'change': '+2.1%', 'color': Colors.green},
          {'name': 'Technology', 'change': '+1.8%', 'color': Colors.green},
          {'name': 'Industrial', 'change': '+1.5%', 'color': Colors.green},
          {'name': 'Chemical', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Financial', 'change': '-0.5%', 'color': Colors.red},
          {'name': 'Utilities', 'change': '+0.8%', 'color': Colors.green},
        ];
      case 'GB':
        return [
          {'name': 'Energy', 'change': '+2.2%', 'color': Colors.green},
          {'name': 'Healthcare', 'change': '+1.9%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+1.1%', 'color': Colors.green},
          {'name': 'Consumer', 'change': '+0.7%', 'color': Colors.green},
          {'name': 'Telecom', 'change': '-0.8%', 'color': Colors.red},
          {'name': 'Real Estate', 'change': '+0.4%', 'color': Colors.green},
        ];
      case 'JP':
        return [
          {'name': 'Automotive', 'change': '+1.5%', 'color': Colors.green},
          {'name': 'Technology', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Gaming', 'change': '+2.8%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+0.9%', 'color': Colors.green},
          {'name': 'Industrial', 'change': '+0.6%', 'color': Colors.green},
          {'name': 'Telecom', 'change': '-0.2%', 'color': Colors.red},
        ];
      default:
        return [
          {'name': 'Technology', 'change': '+1.5%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Healthcare', 'change': '+0.8%', 'color': Colors.green},
          {'name': 'Energy', 'change': '+0.5%', 'color': Colors.green},
          {'name': 'Consumer', 'change': '-0.3%', 'color': Colors.red},
          {'name': 'Utilities', 'change': '+0.2%', 'color': Colors.green},
        ];
    }
  }

  String _getLocationDisplayName(String locationCode) {
    switch (locationCode) {
      case 'US': return 'United States';
      case 'DE': return 'Germany';
      case 'GB': return 'United Kingdom';
      case 'JP': return 'Japan';
      case 'FR': return 'France';
      case 'CA': return 'Canada';
      default: return 'Global';
    }
  }

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
              // Header with location indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VANTYX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Colors.blue, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _getLocationDisplayName(widget.locationCode),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'VANTYX empowers you to gain attention into stock market, research investment plans, VANTYX, which best open book day movements. – Explore live market stocks, new company updates while being guided by greatness',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Last Viewed Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Featured Stock - ${_getLocationDisplayName(widget.locationCode)}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,  // Black text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (isLoading)
                      CircularProgressIndicator(color: colorScheme.onSecondary)
                    else if (lastViewedStock != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockPage(symbol: lastViewedStock!['symbol']),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lastViewedStock!['name'],
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    lastViewedStock!['price'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                lastViewedStock!['change'],
                                style: TextStyle(
                                  color: lastViewedStock!['changeColor'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle buy action
                              _showTransactionDialog('BUY');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'BUY',
                              style: TextStyle(
                                color: Colors.white,  // White text on green button
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle sell action
                              _showTransactionDialog('SELL');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'SELL',
                              style: TextStyle(
                                color: Colors.white,  // White text on red button
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Top Sectors Section
              Text(
                'Top Sectors - ${_getLocationDisplayName(widget.locationCode)}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: topSectors.length,
                itemBuilder: (context, index) {
                  final sector = topSectors[index];
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: colorScheme.onSecondary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sector['name'],
                          style: TextStyle(
                            color: colorScheme.onPrimary,  // Black text
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          sector['change'],
                          style: TextStyle(
                            color: sector['color'],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Learn More Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ready to take control of your financial future? It\'s built with some new tools, detailed insights, and faster access. VANTYX LUXE Premium subscription gives you unlimited access for better trading decisions to easily understand market data and turn insights into reality.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to learn more or premium
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'LEARN MORE',
                        style: TextStyle(
                          color: Colors.white,  // White text on colored button
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

  void _showTransactionDialog(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            '$type ${lastViewedStock?['name'] ?? 'Stock'}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Price: ${lastViewedStock?['price'] ?? 'N/A'}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                // Save transaction data locally
                _saveTransaction(type, lastViewedStock?['symbol'] ?? 'UNKNOWN', 150.00);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$type order placed successfully!'),
                    backgroundColor: type == 'BUY' ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: type == 'BUY' ? Colors.green : Colors.red,
              ),
              child: Text(type, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _saveTransaction(String type, String symbol, double price) {
    // Here you would save to local storage or send to an API
    // For now, we'll just print the transaction
    print('Transaction: $type $symbol at \$${price.toStringAsFixed(2)} in ${widget.locationCode}');
    // You can use shared_preferences or a local database like SQLite
  }
}