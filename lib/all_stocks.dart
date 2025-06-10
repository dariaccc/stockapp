import 'package:flutter/material.dart';
import 'stockpage.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;


class AllStocksPage extends StatefulWidget {
  final String locationCode;
  final String locationName;

  const AllStocksPage({
    super.key,
    required this.locationCode,
    required this.locationName,
  });

  @override
  State<AllStocksPage> createState() => _AllStocksPageState();
}

class _AllStocksPageState extends State<AllStocksPage> {
  List<Map<String, dynamic>> allStocks = [];
  List<Map<String, dynamic>> filteredStocks = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedSector = 'All';
  String sortBy = 'symbol'; // symbol, name, price, change
  bool isAscending = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 Loading stocks for ${widget.locationCode}...');

      // Get stock symbols based on location
      final stockSymbols = _getStockSymbolsForLocation(widget.locationCode);
      print('📋 Stock symbols to fetch: ${stockSymbols.take(10).toList()}...');

      // Use a reasonable batch size to avoid overwhelming the API
      final batchSize = 15; // Fetch 15 stocks at a time
      final symbolsToFetch = stockSymbols.take(batchSize).toList();

      print('🧪 Fetching ${symbolsToFetch.length} stocks...');

      // Use the robust Yahoo Finance method
      final stocksData = await ApiService.getMultipleStocksRobust(symbolsToFetch);

      print('📈 API Response: ${stocksData.length} stocks received');

      if (stocksData.isNotEmpty) {
        // Process and enrich the data
        final enrichedStocks = _enrichStockData(stocksData);

        setState(() {
          allStocks = enrichedStocks;
          filteredStocks = enrichedStocks;
          isLoading = false;
        });

        print('✅ Successfully loaded ${allStocks.length} stocks');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded ${allStocks.length} stocks successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('⚠️ No stocks received, using fallback...');
        await _loadFallbackStocks();
      }

    } catch (e, stackTrace) {
      print('❌ Error loading stocks: $e');
      print('📱 Stack trace: $stackTrace');

      // Use fallback stocks
      await _loadFallbackStocks();

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using demo data - API error occurred'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadStocks,
            ),
          ),
        );
      }
    }
  }

// Add this fallback method
  Future<void> _loadFallbackStocks() async {
    print('🔄 Loading fallback stocks...');

    final fallbackStocks = _generateFallbackStockData(_getStockSymbolsForLocation(widget.locationCode));
    final enrichedStocks = _enrichStockData(fallbackStocks);

    setState(() {
      allStocks = enrichedStocks;
      filteredStocks = enrichedStocks;
      isLoading = false;
    });

    print('✅ Loaded ${allStocks.length} fallback stocks');
  }

// Add this method to generate realistic fallback data
  List<Map<String, dynamic>> _generateFallbackStockData(List<String> symbols) {
    final random = math.Random();

    return symbols.take(20).map((symbol) {
      // Generate realistic base prices for different stocks
      double basePrice;
      switch (symbol) {
        case 'AAPL': basePrice = 175.0; break;
        case 'MSFT': basePrice = 380.0; break;
        case 'GOOGL': basePrice = 142.0; break;
        case 'AMZN': basePrice = 158.0; break;
        case 'TSLA': basePrice = 248.0; break;
        case 'META': basePrice = 485.0; break;
        case 'NVDA': basePrice = 875.0; break;
        case 'JPM': basePrice = 168.0; break;
        case 'JNJ': basePrice = 162.0; break;
        case 'PG': basePrice = 155.0; break;
        default: basePrice = 50.0 + random.nextDouble() * 200; // Random price between $50-250
      }

      // Add some realistic variation (±5%)
      final variation = (random.nextDouble() - 0.5) * 0.1; // ±5%
      final currentPrice = basePrice * (1 + variation);

      // Generate realistic daily change (±3%)
      final changePercent = (random.nextDouble() - 0.5) * 6; // ±3%
      final change = currentPrice * (changePercent / 100);

      // Generate realistic volume
      int volume;
      switch (symbol) {
        case 'AAPL': case 'TSLA': case 'NVDA':
        volume = (30000000 + random.nextInt(40000000)); // High volume stocks
        break;
        case 'META': case 'GOOGL': case 'MSFT':
        volume = (15000000 + random.nextInt(25000000)); // Medium-high volume
        break;
        default:
          volume = (1000000 + random.nextInt(10000000)); // Regular volume
      }

      return {
        'symbol': symbol,
        'price': currentPrice,
        'change': change,
        'changePercent': changePercent.toStringAsFixed(2),
        'volume': volume,
        'lastUpdated': DateTime.now().toIso8601String(),
        'open': currentPrice - change,
        'high': currentPrice + (random.nextDouble() * currentPrice * 0.02), // +2% max
        'low': currentPrice - (random.nextDouble() * currentPrice * 0.02),  // -2% max
      };
    }).toList();
  }

// Add import for math if not already there
// STEP 2: Replace your existing _getStockSymbolsForLocation method with this simplified version:
  List<String> _getStockSymbolsForLocation(String locationCode) {
    switch (locationCode.toUpperCase()) {
      case 'US':
      // Use only major, well-known US stocks that should definitely exist
        return [
          'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA',
          'META', 'NVDA', 'JPM', 'JNJ', 'PG',
          'UNH', 'HD', 'PYPL', 'DIS', 'ADBE',
          'CRM', 'NFLX', 'CMCSA', 'PEP', 'TMO'
        ];

      case 'DE':
        return [
          'SAP', 'ASML', 'SIE', 'BAS', 'ALV',
          'BMW', 'VOW3', 'MBG', 'DTE', 'DB1'
        ];

      case 'GB':
        return [
          'AZN', 'SHEL', 'GSK', 'BP', 'LLOY',
          'BARC', 'VOD', 'HSBA', 'RIO', 'BHP'
        ];

      case 'FR':
        return [
          'MC', 'OR', 'SAN', 'AIR', 'BNP',
          'TTE', 'SAF', 'SU', 'URW', 'CAP'
        ];

      case 'JP':
        return [
          '7203', '6758', '9984', '6861', '8306',
          '9432', '4063', '6367', '4519', '9201'
        ];

      case 'CA':
        return [
          'SHOP', 'RY', 'TD', 'CNR', 'SU',
          'BMO', 'BNS', 'CNQ', 'CP', 'WCN'
        ];

      case 'AU':
        return [
          'CBA', 'BHP', 'ANZ', 'WBC', 'NAB',
          'CSL', 'WES', 'TLS', 'FMG', 'RIO'
        ];

      default:
      // Simple fallback with guaranteed US stocks
        return ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'];
    }
  }

// STEP 3: Add this test method anywhere in your AllStocksPage class:
  Future<void> _testApiDirectly() async {
    print('🧪 Testing API directly...');

    // Test 1: Single stock call
    try {
      print('📞 Testing single stock call for AAPL...');
      final singleStock = await ApiService.getStockQuote('AAPL');
      print('📊 Single stock result: $singleStock');
    } catch (e) {
      print('❌ Single stock test failed: $e');
    }

    // Test 2: Multiple stocks call
    try {
      print('📞 Testing multiple stocks call for [AAPL, MSFT]...');
      final multipleStocks = await ApiService.getMultipleStocks(['AAPL', 'MSFT']);
      print('📊 Multiple stocks result: $multipleStocks');
      print('📊 Count: ${multipleStocks.length}');
    } catch (e) {
      print('❌ Multiple stocks test failed: $e');
    }

    // Test 3: Check your API key and URL
    print('🔑 API Configuration:');
    print('   Base URL: ${ApiService.marketstackBaseUrl}');
    print('   API Key: ${ApiService.marketstackApiKey.substring(0, 8)}...');

    // Test 4: Direct HTTP test
    try {
      print('🌐 Testing direct HTTP call...');
      final url = '${ApiService.marketstackBaseUrl}/eod/latest?access_key=${ApiService.marketstackApiKey}&symbols=AAPL';
      print('🔗 Test URL: $url');

      final response = await http.get(Uri.parse(url));
      print('📡 HTTP Status: ${response.statusCode}');
      print('📄 HTTP Response: ${response.body}');
    } catch (e) {
      print('❌ Direct HTTP test failed: $e');
    }
  }
  // Enrich stock data with additional information
  List<Map<String, dynamic>> _enrichStockData(List<Map<String, dynamic>> stocksData) {
    return stocksData.map((stock) {
      final symbol = stock['symbol'] ?? '';
      return {
        ...stock,
        'companyName': _getCompanyName(symbol),
        'sector': _getStockSector(symbol),
        'marketCap': _estimateMarketCap(symbol, stock['price']?.toDouble() ?? 0.0),
        'isPositive': (stock['change']?.toDouble() ?? 0.0) >= 0,
      };
    }).toList();
  }

  String _getCompanyName(String symbol) {
    final Map<String, String> companyNames = {
      // US Stocks
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'META': 'Meta Platforms Inc.',
      'NVDA': 'NVIDIA Corporation',
      'AMZN': 'Amazon.com Inc.',
      'TSLA': 'Tesla Inc.',
      'NFLX': 'Netflix Inc.',
      'AMD': 'Advanced Micro Devices',
      'INTC': 'Intel Corporation',
      'CRM': 'Salesforce Inc.',
      'ORCL': 'Oracle Corporation',
      'ADBE': 'Adobe Inc.',
      'UBER': 'Uber Technologies',
      'LYFT': 'Lyft Inc.',
      'F': 'Ford Motor Company',
      'GM': 'General Motors',
      'JPM': 'JPMorgan Chase & Co.',
      'BAC': 'Bank of America Corp.',
      'WFC': 'Wells Fargo & Company',
      'GS': 'Goldman Sachs Group',
      'MS': 'Morgan Stanley',
      'C': 'Citigroup Inc.',
      'JNJ': 'Johnson & Johnson',
      'PFE': 'Pfizer Inc.',
      'UNH': 'UnitedHealth Group',
      'ABBV': 'AbbVie Inc.',
      'MRK': 'Merck & Co.',
      'XOM': 'Exxon Mobil Corporation',
      'CVX': 'Chevron Corporation',
      'COP': 'ConocoPhillips',
      'KO': 'Coca-Cola Company',
      'PEP': 'PepsiCo Inc.',
      'WMT': 'Walmart Inc.',
      'TGT': 'Target Corporation',
      'HD': 'Home Depot Inc.',
      'NKE': 'Nike Inc.',
      'VZ': 'Verizon Communications',
      'T': 'AT&T Inc.',
      'CMCSA': 'Comcast Corporation',

      // German Stocks
      'SAP': 'SAP SE',
      'ASML': 'ASML Holding N.V.',
      'SIE': 'Siemens AG',
      'BAS': 'BASF SE',
      'ALV': 'Allianz SE',
      'BMW': 'Bayerische Motoren Werke AG',
      'VOW3': 'Volkswagen AG',
      'MBG': 'Mercedes-Benz Group AG',
      'DTE': 'Deutsche Telekom AG',
      'DB1': 'Deutsche Bank AG',
      'CBK': 'Commerzbank AG',
      'MUV2': 'Munich Re',
      'BEI': 'Beiersdorf AG',
      'ADS': 'Adidas AG',
      'HEN3': 'Henkel AG',
      'LIN': 'Linde plc',
      'SAR': 'Sartorius AG',
      'MRK': 'Merck KGaA',
      'FRE': 'Fresenius SE',
      'RWE': 'RWE AG',
      'IFX': 'Infineon Technologies',
      'FME': 'Fresenius Medical Care',
      'CON': 'Continental AG',
      'DTG': 'Deutsche Telekom AG',

      // UK Stocks
      'AZN': 'AstraZeneca PLC',
      'SHEL': 'Shell PLC',
      'GSK': 'GSK PLC',
      'BP': 'BP PLC',
      'BT-A': 'BT Group PLC',
      'LLOY': 'Lloyds Banking Group',
      'BARC': 'Barclays PLC',
      'VOD': 'Vodafone Group PLC',
      'HSBA': 'HSBC Holdings PLC',
      'RIO': 'Rio Tinto PLC',
      'BHP': 'BHP Group PLC',
      'ULVR': 'Unilever PLC',
      'DGE': 'Diageo PLC',
      'RB': 'Reckitt Benckiser Group',
      'TSCO': 'Tesco PLC',
      'GLEN': 'Glencore PLC',
      'PRU': 'Prudential PLC',
      'NG': 'National Grid PLC',
      'REL': 'RELX PLC',
      'AAL': 'Anglo American PLC',
      'IMB': 'Imperial Brands PLC',
      'LSEG': 'London Stock Exchange Group',
      'CNA': 'Centrica PLC',
      'EXPN': 'Experian PLC',

      // Add more as needed for other countries...
    };

    return companyNames[symbol] ?? '${symbol} Corp.';
  }

  String _getStockSector(String symbol) {
    final Map<String, String> sectors = {
      // Technology
      'AAPL': 'Technology', 'MSFT': 'Technology', 'GOOGL': 'Technology',
      'META': 'Technology', 'NVDA': 'Technology', 'AMD': 'Technology',
      'INTC': 'Technology', 'CRM': 'Technology', 'ORCL': 'Technology',
      'ADBE': 'Technology', 'SAP': 'Technology', 'ASML': 'Technology',
      'IFX': 'Technology',

      // Automotive
      'TSLA': 'Automotive', 'F': 'Automotive', 'GM': 'Automotive',
      'BMW': 'Automotive', 'VOW3': 'Automotive', 'MBG': 'Automotive',

      // Finance
      'JPM': 'Finance', 'BAC': 'Finance', 'WFC': 'Finance', 'GS': 'Finance',
      'MS': 'Finance', 'C': 'Finance', 'ALV': 'Finance', 'DB1': 'Finance',
      'CBK': 'Finance', 'LLOY': 'Finance', 'BARC': 'Finance', 'HSBA': 'Finance',

      // Healthcare
      'JNJ': 'Healthcare', 'PFE': 'Healthcare', 'UNH': 'Healthcare',
      'ABBV': 'Healthcare', 'MRK': 'Healthcare', 'AZN': 'Healthcare',
      'GSK': 'Healthcare', 'SAR': 'Healthcare', 'FRE': 'Healthcare',
      'FME': 'Healthcare',

      // Energy
      'XOM': 'Energy', 'CVX': 'Energy', 'COP': 'Energy', 'BP': 'Energy',
      'SHEL': 'Energy', 'RWE': 'Energy',

      // Consumer Goods
      'KO': 'Consumer Goods', 'PEP': 'Consumer Goods', 'NKE': 'Consumer Goods',
      'BEI': 'Consumer Goods', 'ADS': 'Consumer Goods', 'HEN3': 'Consumer Goods',
      'ULVR': 'Consumer Goods', 'DGE': 'Consumer Goods', 'RB': 'Consumer Goods',

      // Retail
      'WMT': 'Retail', 'TGT': 'Retail', 'HD': 'Retail', 'TSCO': 'Retail',

      // Entertainment/Media
      'NFLX': 'Entertainment', 'CMCSA': 'Entertainment',

      // Transportation
      'UBER': 'Transportation', 'LYFT': 'Transportation',

      // Telecommunications
      'VZ': 'Telecommunications', 'T': 'Telecommunications',
      'DTE': 'Telecommunications', 'BT-A': 'Telecommunications',
      'VOD': 'Telecommunications',

      // Industrial
      'SIE': 'Industrial', 'CON': 'Industrial',

      // Chemicals
      'BAS': 'Chemicals', 'LIN': 'Chemicals',

      // Insurance
      'MUV2': 'Insurance', 'PRU': 'Insurance',

      // Mining
      'RIO': 'Mining', 'BHP': 'Mining', 'GLEN': 'Mining', 'AAL': 'Mining',

      // Utilities
      'NG': 'Utilities',

      // E-commerce
      'AMZN': 'E-commerce',
    };

    return sectors[symbol] ?? 'General';
  }

  String _estimateMarketCap(String symbol, double price) {
    // Estimated shares outstanding for market cap calculation
    final Map<String, double> sharesOutstanding = {
      'AAPL': 16000000000, 'MSFT': 7500000000, 'GOOGL': 6000000000,
      'AMZN': 5000000000, 'TSLA': 3000000000, 'META': 2500000000,
      'NVDA': 25000000000, 'SAP': 1200000000, 'BMW': 650000000,
      'VOW3': 500000000, // Add more as needed
    };

    final shares = sharesOutstanding[symbol] ?? 1000000000; // Default 1B shares
    final marketCapValue = price * shares;

    if (marketCapValue >= 1000000000000) {
      return '\$${(marketCapValue / 1000000000000).toStringAsFixed(2)}T';
    } else if (marketCapValue >= 1000000000) {
      return '\$${(marketCapValue / 1000000000).toStringAsFixed(1)}B';
    } else if (marketCapValue >= 1000000) {
      return '\$${(marketCapValue / 1000000).toStringAsFixed(0)}M';
    } else {
      return '\$${marketCapValue.toStringAsFixed(0)}';
    }
  }

  void _filterAndSortStocks() {
    List<Map<String, dynamic>> filtered = allStocks.where((stock) {
      final matchesSearch = searchQuery.isEmpty ||
          stock['symbol'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          stock['companyName'].toString().toLowerCase().contains(searchQuery.toLowerCase());

      final matchesSector = selectedSector == 'All' || stock['sector'] == selectedSector;

      return matchesSearch && matchesSector;
    }).toList();

    // Sort the filtered results
    filtered.sort((a, b) {
      dynamic aValue, bValue;

      switch (sortBy) {
        case 'symbol':
          aValue = a['symbol'].toString();
          bValue = b['symbol'].toString();
          break;
        case 'name':
          aValue = a['companyName'].toString();
          bValue = b['companyName'].toString();
          break;
        case 'price':
          aValue = a['price']?.toDouble() ?? 0.0;
          bValue = b['price']?.toDouble() ?? 0.0;
          break;
        case 'change':
          aValue = a['change']?.toDouble() ?? 0.0;
          bValue = b['change']?.toDouble() ?? 0.0;
          break;
        default:
          aValue = a['symbol'].toString();
          bValue = b['symbol'].toString();
      }

      int comparison;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return isAscending ? comparison : -comparison;
    });

    setState(() {
      filteredStocks = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterAndSortStocks();
  }

  void _onSectorChanged(String sector) {
    setState(() {
      selectedSector = sector;
    });
    _filterAndSortStocks();
  }

  void _onSortChanged(String newSortBy) {
    setState(() {
      if (sortBy == newSortBy) {
        isAscending = !isAscending;
      } else {
        sortBy = newSortBy;
        isAscending = true;
      }
    });
    _filterAndSortStocks();
  }

  List<String> _getAvailableSectors() {
    final sectors = allStocks.map((stock) => stock['sector'].toString()).toSet().toList();
    sectors.sort();
    return ['All', ...sectors];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Stocks - ${widget.locationName}',
          style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _loadStocks,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.onSecondary),
            const SizedBox(height: 16),
            Text(
              'Loading stocks for ${widget.locationName}...',
              style: TextStyle(
                color: colorScheme.onSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: colorScheme.onPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search stocks...',
                    hintStyle: TextStyle(color: colorScheme.onSecondary.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSecondary),
                    filled: true,
                    fillColor: colorScheme.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter and Sort Row
                Row(
                  children: [
                    // Sector Filter
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedSector,
                            onChanged: (value) => _onSectorChanged(value!),
                            dropdownColor: colorScheme.secondary,
                            style: TextStyle(color: colorScheme.onPrimary, fontSize: 14),
                            items: _getAvailableSectors().map((sector) {
                              return DropdownMenuItem(
                                value: sector,
                                child: Text(sector, overflow: TextOverflow.ellipsis, softWrap: false,),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Sort Options
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sortBy,
                            onChanged: (value) => _onSortChanged(value!),
                            dropdownColor: colorScheme.secondary,
                            style: TextStyle(color: colorScheme.onPrimary, fontSize: 14),
                            items: [
                              DropdownMenuItem(value: 'symbol', child: Text('Symbol')),
                              DropdownMenuItem(value: 'name', child: Text('Name')),
                              DropdownMenuItem(value: 'price', child: Text('Price')),
                              DropdownMenuItem(value: 'change', child: Text('Change')),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Sort Direction
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isAscending = !isAscending;
                        });
                        _filterAndSortStocks();
                      },
                      icon: Icon(
                        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Results count
                Text(
                  '${filteredStocks.length} stocks found',
                  style: TextStyle(
                    color: colorScheme.onSecondary.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Stocks List
          Expanded(
            child: filteredStocks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: colorScheme.onSecondary.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No stocks found',
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      color: colorScheme.onSecondary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                return _buildStockItem(stock, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock, ColorScheme colorScheme) {
    final isPositive = stock['isPositive'] ?? false;
    final price = stock['price']?.toDouble() ?? 0.0;
    final change = stock['change']?.toDouble() ?? 0.0;
    final changePercent = stock['changePercent']?.toString() ?? '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSecondary.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockPage(symbol: stock['symbol']),
            ),
          );
        },
        child: Row(
          children: [
            // Left side - Stock info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stock['symbol'],
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.onSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock['sector'],
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stock['companyName'],
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stock['marketCap'],
                    style: TextStyle(
                      color: colorScheme.onSecondary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Right side - Price info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${changePercent}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}\$${change.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSecondary.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}