import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'stockpage.dart';
import 'news_service.dart'; // Import your NewsService
import 'all_stocks.dart';

class Radar extends StatefulWidget {
  final String locationCode;

  const Radar({super.key, this.locationCode = 'DE'});

  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> {
  List<Map<String, dynamic>> topPerformers = [];
  List<Map<String, dynamic>> worstPerformers = [];
  List<Map<String, dynamic>> newsItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRadarData();
  }

  @override
  void didUpdateWidget(Radar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when location changes
    if (oldWidget.locationCode != widget.locationCode) {
      _loadRadarData();
    }
  }

  Future<void> _loadRadarData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load stock data based on location
      final stockData = _getStockDataForLocation(widget.locationCode);

      print('🔄 Loading news for location: ${widget.locationCode}');

      // Load real news from NewsService
      final realNews = await NewsService.getLocationBasedNews(widget.locationCode);

      print('✅ News loaded successfully: ${realNews.length} articles');
      print('📰 First article: ${realNews.isNotEmpty ? realNews[0]['title'] : 'No articles'}');

      // Force use of real news even if empty (for debugging)
      List<Map<String, dynamic>> finalNewsItems;
      if (realNews.isNotEmpty) {
        finalNewsItems = _formatNewsForCarousel(realNews);
        print('🎯 Using REAL news: ${finalNewsItems.length} items');
      } else {
        print('⚠️ Real news is empty, checking why...');
        // Try to get financial news directly
        final directNews = await NewsService.getFinancialNews(
          category: 'business',
          country: _getLocationDisplayName(widget.locationCode),
          pageSize: 5,
        );
        print('🔍 Direct news call result: ${directNews.length} articles');

        if (directNews.isNotEmpty) {
          finalNewsItems = _formatNewsForCarousel(directNews);
          print('🎯 Using DIRECT news: ${finalNewsItems.length} items');
        } else {
          print('❌ Both API calls failed, using fallback');
          finalNewsItems = _getFallbackNews();
        }
      }

      setState(() {
        topPerformers = stockData['topPerformers'] ?? [];
        worstPerformers = stockData['worstPerformers'] ?? [];
        newsItems = finalNewsItems;
        isLoading = false;
      });

      print('🎠 Final news items in carousel: ${newsItems.length}');

    } catch (e) {
      print('❌ Error loading radar data: $e');
      print('📱 Stack trace: ${StackTrace.current}');

      // Try one more time with a direct API call
      try {
        print('🔄 Attempting direct NewsAPI call as last resort...');
        final lastResortNews = await NewsService.getFinancialNews(
          category: 'technology',
          country: 'us',
          pageSize: 3,
        );

        if (lastResortNews.isNotEmpty) {
          print('✅ Last resort news worked: ${lastResortNews.length} articles');
          final stockData = _getStockDataForLocation(widget.locationCode);
          setState(() {
            topPerformers = stockData['topPerformers'] ?? [];
            worstPerformers = stockData['worstPerformers'] ?? [];
            newsItems = _formatNewsForCarousel(lastResortNews);
            isLoading = false;
          });
          return;
        }
      } catch (lastResortError) {
        print('❌ Last resort also failed: $lastResortError');
      }

      // Final fallback to static data
      final data = _getDataForLocation(widget.locationCode);
      setState(() {
        topPerformers = data['topPerformers'] ?? [];
        worstPerformers = data['worstPerformers'] ?? [];
        newsItems = data['news'] ?? [];
        isLoading = false;
      });

      print('🔄 Using fallback news: ${newsItems.length} items');
    }
  }

  // Format news from NewsService for carousel display
  List<Map<String, dynamic>> _formatNewsForCarousel(List<Map<String, dynamic>> apiNews) {
    print('🔄 Formatting ${apiNews.length} news articles for carousel');

    if (apiNews.isEmpty) {
      print('⚠️ No API news available, returning fallback news');
      // Return fallback news if no API news available
      return _getFallbackNews();
    }

    final formattedNews = apiNews.take(5).map((news) {
      print('📰 Processing article: ${news['title']}');
      print('🖼️ Image URL: ${news['imageUrl']}');

      return {
        'title': news['title'] ?? 'No Title',
        'description': news['description'] ?? 'No description available',
        'image': news['imageUrl']?.isNotEmpty == true
            ? news['imageUrl']
            : 'assets/images/news.png', // Fallback image
        'url': news['url'] ?? '',
        'source': news['source'] ?? 'Unknown',
        'publishedAt': news['publishedAt'] ?? '',
      };
    }).toList();

    print('✅ Formatted ${formattedNews.length} articles for carousel');
    return formattedNews;
  }

  // Fallback news when API fails
  List<Map<String, dynamic>> _getFallbackNews() {
    return [
      {
        'title': 'Global Markets Show Mixed Signals',
        'description': 'Stock markets worldwide displaying varied performance amid economic uncertainties...',
        'image': 'assets/images/news.png',
        'source': 'Market Watch',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': 'Technology Sector Innovation Drives Growth',
        'description': 'Major tech companies show strong performance with AI and cloud computing innovations...',
        'image': 'assets/images/planet.png',
        'source': 'Tech News',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'title': 'Central Bank Policy Updates',
        'description': 'Latest monetary policy decisions continue to influence market sentiment...',
        'image': 'assets/images/news-placeholder.png',
        'source': 'Financial Times',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
    ];
  }

  Map<String, List<Map<String, dynamic>>> _getStockDataForLocation(String locationCode) {
    switch (locationCode) {
      case 'US':
        return {
          'topPerformers': [
            {'symbol': 'NVDA', 'name': 'NVIDIA Corp', 'change': '+15.2%', 'price': '\$875.50'},
            {'symbol': 'META', 'name': 'Meta Platforms', 'change': '+8.7%', 'price': '\$485.30'},
            {'symbol': 'AMD', 'name': 'Advanced Micro Devices', 'change': '+6.4%', 'price': '\$158.90'},
          ],
          'worstPerformers': [
            {'symbol': 'TSLA', 'name': 'Tesla Inc.', 'change': '-8.1%', 'price': '\$248.50'},
            {'symbol': 'NFLX', 'name': 'Netflix Inc.', 'change': '-5.3%', 'price': '\$512.40'},
            {'symbol': 'UBER', 'name': 'Uber Technologies', 'change': '-4.2%', 'price': '\$68.25'},
          ],
        };
      case 'DE':
        return {
          'topPerformers': [
            {'symbol': 'SAP', 'name': 'SAP SE', 'change': '+5.2%', 'price': '€142.30'},
            {'symbol': 'ASML', 'name': 'ASML Holding', 'change': '+4.8%', 'price': '€785.60'},
            {'symbol': 'SIE', 'name': 'Siemens AG', 'change': '+3.1%', 'price': '€158.90'},
          ],
          'worstPerformers': [
            {'symbol': 'BAS', 'name': 'BASF SE', 'change': '-2.3%', 'price': '€47.82'},
            {'symbol': 'ALV', 'name': 'Allianz SE', 'change': '-1.8%', 'price': '€245.60'},
            {'symbol': 'VW', 'name': 'Volkswagen AG', 'change': '-1.5%', 'price': '€108.45'},
          ],
        };
      case 'GB':
        return {
          'topPerformers': [
            {'symbol': 'AZN', 'name': 'AstraZeneca PLC', 'change': '+3.5%', 'price': '£122.60'},
            {'symbol': 'SHEL', 'name': 'Shell PLC', 'change': '+2.8%', 'price': '£28.45'},
            {'symbol': 'GSK', 'name': 'GSK PLC', 'change': '+2.1%', 'price': '£15.82'},
          ],
          'worstPerformers': [
            {'symbol': 'BP', 'name': 'BP PLC', 'change': '-1.3%', 'price': '£5.42'},
            {'symbol': 'BT', 'name': 'BT Group PLC', 'change': '-0.8%', 'price': '£1.28'},
            {'symbol': 'LLOY', 'name': 'Lloyds Banking Group', 'change': '-0.5%', 'price': '£0.52'},
          ],
        };
      case 'JP':
        return {
          'topPerformers': [
            {'symbol': '7203', 'name': 'Toyota Motor', 'change': '+2.5%', 'price': '¥2,845'},
            {'symbol': '6758', 'name': 'Sony Group', 'change': '+1.8%', 'price': '¥12,450'},
            {'symbol': '9984', 'name': 'SoftBank Group', 'change': '+1.2%', 'price': '¥6,890'},
          ],
          'worstPerformers': [
            {'symbol': '8306', 'name': 'Mitsubishi UFJ', 'change': '-1.1%', 'price': '¥1,234'},
            {'symbol': '9983', 'name': 'Fast Retailing', 'change': '-0.9%', 'price': '¥89,500'},
            {'symbol': '4689', 'name': 'Yahoo Japan', 'change': '-0.7%', 'price': '¥567'},
          ],
        };
      default:
        return {
          'topPerformers': [
            {'symbol': 'AAPL', 'name': 'Apple Inc.', 'change': '+2.3%', 'price': '\$175.50'},
            {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'change': '+1.8%', 'price': '\$142.80'},
            {'symbol': 'MSFT', 'name': 'Microsoft Corp.', 'change': '+1.2%', 'price': '\$378.85'},
          ],
          'worstPerformers': [
            {'symbol': 'TSLA', 'name': 'Tesla Inc.', 'change': '-3.1%', 'price': '\$248.50'},
            {'symbol': 'NFLX', 'name': 'Netflix Inc.', 'change': '-2.5%', 'price': '\$512.40'},
            {'symbol': 'UBER', 'name': 'Uber Technologies', 'change': '-1.8%', 'price': '\$68.25'},
          ],
        };
    }
  }

  // Keep the old method for complete fallback
  Map<String, List<Map<String, dynamic>>> _getDataForLocation(String locationCode) {
    final stockData = _getStockDataForLocation(locationCode);
    return {
      ...stockData,
      'news': _getFallbackNews(),
    };
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

  Widget _buildNewsCarousel() {
    if (newsItems.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'No news available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return CarouselSlider(
      items: newsItems.map((news) => _buildNewsItem(news)).toList(),
      options: CarouselOptions(
        height: 500,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enableInfiniteScroll: newsItems.length > 1,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
      ),
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> news) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        // Background image
        Container(
          height: 500,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: news['image'].toString().startsWith('http')
                  ? NetworkImage(news['image']) as ImageProvider
                  : AssetImage(news['image']),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Handle image loading errors
                print('Error loading image: $exception');
              },
            ),
          ),
          // Add fallback color if image fails to load
          child: news['image'].toString().startsWith('http')
              ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          )
              : null,
        ),
        // Overlay gradient
        Container(
          width: MediaQuery.of(context).size.width,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // News content
        Container(
          margin: const EdgeInsets.all(10),
          height: 140,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorScheme.tertiary.withOpacity(0.95),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News source and time
              if (news['source'] != null || news['publishedAt'] != null)
                Row(
                  children: [
                    if (news['source'] != null)
                      Text(
                        news['source'],
                        style: TextStyle(
                          color: colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (news['source'] != null && news['publishedAt'] != null)
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: colorScheme.onPrimary.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                    if (news['publishedAt'] != null)
                      Text(
                        NewsService.formatTimeAgo(news['publishedAt']),
                        style: TextStyle(
                          color: colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              if (news['source'] != null || news['publishedAt'] != null)
                const SizedBox(height: 6),
              // News title
              Text(
                news['title'],
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // News description
              Expanded(
                child: Text(
                  news['description'],
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Location indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Radar - ${_getLocationDisplayName(widget.locationCode)}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllStocksPage(
                          locationCode: widget.locationCode,
                          locationName: _getLocationDisplayName(widget.locationCode),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSecondary,
                    foregroundColor: colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 20,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View All Stocks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // News Carousel with loading state
              isLoading
                  ? Container(
                height: 500,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : _buildNewsCarousel(),

              const SizedBox(height: 30),

              // Top Performers Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF000000)),
                  color: colorScheme.secondary,
                ),
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.onSecondary,
                      ),
                      child: Text(
                        "Top performers today",
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isLoading)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      ...topPerformers.map((stock) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockPage(symbol: stock['symbol']),
                            ),
                          );
                        },
                        child: Container(
                          width: 310,
                          height: 55,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.onPrimary),
                            color: colorScheme.tertiary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stock['symbol'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      stock['name'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary.withOpacity(0.7),
                                        fontSize: 9,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stock['price'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      stock['change'],
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: colorScheme.onSecondary.withOpacity(0.5),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      )),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Worst Performers Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF000000)),
                  color: colorScheme.secondary,
                ),
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFFFFFFF),
                      ),
                      child: const Text(
                        "Worst performers today",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isLoading)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      ...worstPerformers.map((stock) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockPage(symbol: stock['symbol']),
                            ),
                          );
                        },
                        child: Container(
                          width: 310,
                          height: 55,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.onPrimary),
                            color: colorScheme.tertiary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stock['symbol'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      stock['name'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary.withOpacity(0.7),
                                        fontSize: 9,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      stock['price'],
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      stock['change'],
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: colorScheme.onSecondary.withOpacity(0.5),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      )),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}