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
      print('🏠 Loading home data for ${widget.locationCode}...');

      // Get different stock based on location
      String primaryStock = _getPrimaryStockForLocation(widget.locationCode);
      print('📊 Primary stock for ${widget.locationCode}: $primaryStock');

      // Try to get real stock data first
      final stockQuote = await ApiService.getStockQuote(primaryStock);

      if (stockQuote != null) {
        print('✅ Successfully loaded real data for $primaryStock');
        final isPositive = (stockQuote['change'] ?? 0) >= 0;
        final price = stockQuote['price'] ?? 0.0;
        final changePercent = stockQuote['changePercent'] ?? '0.00';

        setState(() {
          lastViewedStock = {
            'symbol': stockQuote['symbol'],
            'name': _getStockName(stockQuote['symbol']),
            'price': _formatPrice(price, widget.locationCode),
            'change': '${isPositive ? '+' : ''}$changePercent%',
            'changeColor': isPositive ? Colors.green : Colors.red,
          };
        });
      } else {
        print('⚠️ Real API failed, using fallback for $primaryStock');
        // Fallback data based on location
        final fallbackData = _getFallbackDataForLocation(widget.locationCode);
        setState(() {
          lastViewedStock = fallbackData;
        });
      }

      // Get recommended stocks based on location and try to fetch some real data
      List<String> recommendedStocks = _getRecommendedStocksForLocation(widget.locationCode);
      print('📋 Recommended stocks: ${recommendedStocks.take(5).toList()}');

      // Try to get real data for a few stocks to calculate sector performance
      List<Map<String, dynamic>> stocksData = [];
      try {
        final limitedStocks = recommendedStocks.take(5).toList(); // Limit to avoid too many API calls
        stocksData = await ApiService.getMultipleStocks(limitedStocks);
        print('📈 Retrieved ${stocksData.length} real stocks for sector calculation');
      } catch (e) {
        print('⚠️ Failed to get multiple stocks: $e');
      }

      // Calculate sector data based on location and actual stock performance
      setState(() {
        topSectors = _getSectorsForLocation(widget.locationCode, stocksData);
        isLoading = false;
      });

      print('✅ Home data loaded successfully');
    } catch (e) {
      print('❌ Error loading stock data: $e');
      // Set fallback data based on location
      setState(() {
        lastViewedStock = _getFallbackDataForLocation(widget.locationCode);
        topSectors = _getSectorsForLocation(widget.locationCode, []);
        isLoading = false;
      });
    }
  }

  String _formatPrice(double price, String locationCode) {
    switch (locationCode) {
      case 'DE':
        return '€${price.toStringAsFixed(2)}';
      case 'GB':
        return '£${price.toStringAsFixed(2)}';
      case 'JP':
        return '¥${price.toStringAsFixed(0)}';
      case 'CA':
        return 'C\$${price.toStringAsFixed(2)}';
      case 'US':
      default:
        return '\$${price.toStringAsFixed(2)}';
    }
  }

  String _getPrimaryStockForLocation(String locationCode) {
    switch (locationCode) {
      case 'US': return 'AAPL';
      case 'DE': return 'SAP';  // German SAP stock
      case 'GB': return 'AZN';  // UK AstraZeneca
      case 'JP': return '7203'; // Toyota
      case 'FR': return 'MC';   // LVMH (French luxury)
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
      case 'MC': return 'LVMH';
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
          'price': '\$175.50',
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
      case 'FR':
        return {
          'symbol': 'MC',
          'name': 'LVMH',
          'price': '€785.40',
          'change': '+1.2%',
          'changeColor': Colors.green,
        };
      case 'CA':
        return {
          'symbol': 'SHOP',
          'name': 'Shopify Inc.',
          'price': 'C\$85.25',
          'change': '+3.1%',
          'changeColor': Colors.green,
        };
      default:
        return {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'price': '\$175.50',
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
        return ['AZN', 'SHEL', 'BP', 'ULVR', 'GSK', 'LLOY', 'BARC'];
      case 'JP':
        return ['7203', '6758', '9984', '6861', '8306', '9983', '4689'];
      case 'FR':
        return ['MC', 'OR', 'AIR', 'BNP', 'TTE', 'SAN', 'CAP'];
      case 'CA':
        return ['SHOP', 'RY', 'TD', 'CNR', 'SU', 'BMO', 'BNS'];
      default:
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'];
    }
  }

  List<Map<String, dynamic>> _getSectorsForLocation(String locationCode, List<dynamic> stocksData) {
    // Calculate real sector changes if we have stock data
    String techChange = '+1.5%';
    Color techColor = Colors.green;

    if (stocksData.isNotEmpty) {
      // Use first stock's performance as a base
      final firstStock = stocksData[0];
      if (firstStock['changePercent'] != null) {
        final changePercent = double.tryParse(firstStock['changePercent'].toString()) ?? 1.5;
        techChange = '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%';
        techColor = changePercent >= 0 ? Colors.green : Colors.red;
      }
    }

    switch (locationCode) {
      case 'US':
        return [
          {'name': 'Technology', 'change': techChange, 'color': techColor},
          {'name': 'Healthcare', 'change': '+1.8%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Consumer', 'change': '+0.8%', 'color': Colors.green},
          {'name': 'Energy', 'change': '-0.3%', 'color': Colors.red},
          {'name': 'Utilities', 'change': '+0.5%', 'color': Colors.green},
        ];
      case 'DE':
        return [
          {'name': 'Automotive', 'change': '+2.1%', 'color': Colors.green},
          {'name': 'Technology', 'change': techChange, 'color': techColor},
          {'name': 'Industrial', 'change': '+1.5%', 'color': Colors.green},
          {'name': 'Chemical', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Financial', 'change': '-0.5%', 'color': Colors.red},
          {'name': 'Utilities', 'change': '+0.8%', 'color': Colors.green},
        ];
      case 'GB':
        return [
          {'name': 'Energy', 'change': '+2.2%', 'color': Colors.green},
          {'name': 'Healthcare', 'change': techChange, 'color': techColor},
          {'name': 'Financial', 'change': '+1.1%', 'color': Colors.green},
          {'name': 'Consumer', 'change': '+0.7%', 'color': Colors.green},
          {'name': 'Telecom', 'change': '-0.8%', 'color': Colors.red},
          {'name': 'Real Estate', 'change': '+0.4%', 'color': Colors.green},
        ];
      case 'JP':
        return [
          {'name': 'Automotive', 'change': techChange, 'color': techColor},
          {'name': 'Technology', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Gaming', 'change': '+2.8%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+0.9%', 'color': Colors.green},
          {'name': 'Industrial', 'change': '+0.6%', 'color': Colors.green},
          {'name': 'Telecom', 'change': '-0.2%', 'color': Colors.red},
        ];
      case 'FR':
        return [
          {'name': 'Luxury', 'change': techChange, 'color': techColor},
          {'name': 'Energy', 'change': '+1.8%', 'color': Colors.green},
          {'name': 'Aerospace', 'change': '+1.5%', 'color': Colors.green},
          {'name': 'Financial', 'change': '+1.1%', 'color': Colors.green},
          {'name': 'Utilities', 'change': '+0.7%', 'color': Colors.green},
          {'name': 'Telecom', 'change': '-0.4%', 'color': Colors.red},
        ];
      case 'CA':
        return [
          {'name': 'Technology', 'change': techChange, 'color': techColor},
          {'name': 'Financial', 'change': '+1.4%', 'color': Colors.green},
          {'name': 'Energy', 'change': '+2.1%', 'color': Colors.green},
          {'name': 'Materials', 'change': '+1.2%', 'color': Colors.green},
          {'name': 'Utilities', 'change': '+0.8%', 'color': Colors.green},
          {'name': 'Real Estate', 'change': '+0.3%', 'color': Colors.green},
        ];
      default:
        return [
          {'name': 'Technology', 'change': techChange, 'color': techColor},
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
                      'VANTYX empowers you to gain insights into the stock market, research investment plans, and explore live market movements. Discover stocks, company updates, and market trends in ${_getLocationDisplayName(widget.locationCode)}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                  border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Featured Stock - ${_getLocationDisplayName(widget.locationCode)}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (isLoading)
                      Container(
                        height: 80,
                        child: Center(
                          child: CircularProgressIndicator(color: colorScheme.onSecondary),
                        ),
                      )
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
                            border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lastViewedStock!['name'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lastViewedStock!['symbol'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lastViewedStock!['price'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    lastViewedStock!['change'],
                                    style: TextStyle(
                                      color: lastViewedStock!['changeColor'],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    (lastViewedStock!['changeColor'] == Colors.green)
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: lastViewedStock!['changeColor'],
                                    size: 20,
                                  ),
                                ],
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
                              _showTransactionDialog('BUY');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'BUY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showTransactionDialog('SELL');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'SELL',
                              style: TextStyle(
                                color: Colors.white,
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
                      border: Border.all(color: colorScheme.onSecondary.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sector['name'],
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sector['color'] == Colors.green
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: sector['color'],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sector['change'],
                              style: TextStyle(
                                color: sector['color'],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                      'Ready to take control of your financial future? VANTYX provides detailed insights, real-time data, and powerful tools to help you make better trading decisions in ${_getLocationDisplayName(widget.locationCode)} markets.',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Premium features coming soon!'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'LEARN MORE',
                        style: TextStyle(
                          color: Colors.white,
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
    final TextEditingController quantityController = TextEditingController();

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
                controller: quantityController,
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
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0) {
                  // Save transaction data locally
                  _saveTransaction(type, lastViewedStock?['symbol'] ?? 'UNKNOWN', 150.00, quantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type order for $quantity shares placed successfully!'),
                      backgroundColor: type == 'BUY' ? Colors.green : Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
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

  void _saveTransaction(String type, String symbol, double price, int quantity) {
    // Here you would save to local storage or send to an API
    // For now, we'll just print the transaction
    print('Transaction: $type $quantity shares of $symbol at \$${price.toStringAsFixed(2)} in ${widget.locationCode}');
    // You can use shared_preferences or a local database like SQLite
  }
}