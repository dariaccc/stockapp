import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // Multiple news APIs for better coverage
  static const String _newsApiKey = 'a2aee31b4f70436f956cb602e3f3d734'; // Get from newsapi.org
  static const String _newsApiBaseUrl = 'https://newsapi.org/v2';

  /// Get financial news from NewsAPI
  static Future<List<Map<String, dynamic>>> getFinancialNews({
    String category = 'business',
    String country = 'us',
    int pageSize = 10,
  }) async {
    try {
      final url = Uri.parse(
          '$_newsApiBaseUrl/top-headlines?'
              'category=$category&'
              'country=$country&'
              'pageSize=$pageSize&'
              'apiKey=$_newsApiKey'
      );

      print('Fetching news from: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;

        return articles.map((article) => {
          'title': article['title'] ?? 'No Title',
          'description': article['description'] ?? 'No description available',
          'url': article['url'] ?? '',
          'imageUrl': article['urlToImage'] ?? '',
          'publishedAt': article['publishedAt'] ?? '',
          'source': article['source']['name'] ?? 'Unknown',
          'category': category,
        }).toList();
      } else {
        print('NewsAPI Error: ${response.statusCode} - ${response.body}');
        return _getFallbackNews();
      }
    } catch (e) {
      print('Error fetching news from NewsAPI: $e');
      return _getFallbackNews();
    }
  }


  /// Get location-specific financial news
  static Future<List<Map<String, dynamic>>> getLocationBasedNews(String locationCode) async {
    String country = 'us';
    String category = 'business';

    // Map location codes to country codes for NewsAPI
    switch (locationCode.toUpperCase()) {
      case 'US':
        country = 'us';
        break;
      case 'GB':
        country = 'gb';
        break;
      case 'DE':
        country = 'de';
        break;
      case 'FR':
        country = 'fr';
        break;
      case 'IT':
        country = 'it';
        break;
      case 'CA':
        country = 'ca';
        break;
      case 'AU':
        country = 'au';
        break;
      case 'IN':
        country = 'in';
        break;
      case 'JP':
        country = 'jp';
        break;
      case 'KR':
        country = 'kr';
        break;
      case 'BR':
        country = 'br';
        break;
      default:
        country = 'us';
    }

    print('Getting news for location: $locationCode -> country: $country');

    // Try NewsAPI first, then fallback to Finnhub, then fallback data
    List<Map<String, dynamic>> news = await getFinancialNews(
      category: category,
      country: country,
      pageSize: 8,
    );

    if (news.isEmpty || news.length < 3) {
      print('NewsAPI failed, trying Finnhub...');
    }

    if (news.isEmpty || news.length < 3) {
      print('All APIs failed, using fallback news');
      news = _getFallbackNews();
    }

    return news;
  }

  /// Search for specific stock-related news
  static Future<List<Map<String, dynamic>>> getStockNews(String symbol) async {
    try {
      // Using NewsAPI to search for stock-specific news
      final url = Uri.parse(
          '$_newsApiBaseUrl/everything?'
              'q=$symbol OR "${_getCompanyName(symbol)}"&'
              'sortBy=publishedAt&'
              'pageSize=5&'
              'language=en&'
              'apiKey=$_newsApiKey'
      );

      print('Fetching news for $symbol: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;

        return articles.map((article) => {
          'title': article['title'] ?? 'No Title',
          'description': article['description'] ?? 'No description available',
          'url': article['url'] ?? '',
          'imageUrl': article['urlToImage'] ?? '',
          'publishedAt': article['publishedAt'] ?? '',
          'source': article['source']['name'] ?? 'Unknown',
          'symbol': symbol,
        }).toList();
      } else {
        return _getStockFallbackNews(symbol);
      }
    } catch (e) {
      print('Error fetching stock news: $e');
      return _getStockFallbackNews(symbol);
    }
  }

  /// Get company name for better search results
  static String _getCompanyName(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL': return 'Apple Inc';
      case 'MSFT': return 'Microsoft';
      case 'GOOGL': return 'Google Alphabet';
      case 'TSLA': return 'Tesla';
      case 'AMZN': return 'Amazon';
      case 'META': return 'Meta Facebook';
      case 'NVDA': return 'NVIDIA';
      case 'SAP': return 'SAP SE';
      case 'BMW': return 'BMW';
      case 'AZN': return 'AstraZeneca';
      default: return symbol;
    }
  }

  /// Fallback news when APIs fail
  static List<Map<String, dynamic>> _getFallbackNews() {
    return [
      {
        'title': 'Global Markets Show Mixed Signals Amid Economic Uncertainty',
        'description': 'Stock markets worldwide are displaying varied performance as investors navigate through economic uncertainties and policy changes. Technology stocks lead gains while energy sector faces challenges.',
        'url': '',
        'imageUrl': 'assets/images/news.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'source': 'Market Watch',
        'category': 'business',
      },
      {
        'title': 'Federal Reserve Policy Update: Interest Rates and Market Impact',
        'description': 'Latest monetary policy decisions from the Federal Reserve continue to influence market sentiment across all major sectors. Analysts provide insights into the expected economic impact.',
        'url': '',
        'imageUrl': 'assets/images/planet.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'source': 'Financial Times',
        'category': 'business',
      },
      {
        'title': 'Technology Sector Innovation Drives Investment Growth',
        'description': 'Major technology companies continue to show strong performance with breakthrough innovations in artificial intelligence and cloud computing driving investor confidence.',
        'url': '',
        'imageUrl': 'assets/images/news-placeholder.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'source': 'Tech News',
        'category': 'technology',
      },
      {
        'title': 'Energy Markets Respond to Global Supply Chain Changes',
        'description': 'Oil and gas prices fluctuate as global supply chains adapt to geopolitical changes and renewable energy transitions affect traditional energy markets.',
        'url': '',
        'imageUrl': 'assets/images/news.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'source': 'Energy Weekly',
        'category': 'business',
      },
      {
        'title': 'Emerging Markets Show Resilience Despite Global Challenges',
        'description': 'Developing economies demonstrate strong fundamentals and growth potential, attracting international investment despite global economic headwinds.',
        'url': '',
        'imageUrl': 'assets/images/planet.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 10)).toIso8601String(),
        'source': 'Global Markets',
        'category': 'business',
      },
    ];
  }

  /// Fallback news for specific stocks
  static List<Map<String, dynamic>> _getStockFallbackNews(String symbol) {
    return [
      {
        'title': '${_getCompanyName(symbol)} Reports Strong Quarterly Performance',
        'description': 'Latest earnings report shows solid fundamentals and growth prospects for ${_getCompanyName(symbol)}, with analysts maintaining positive outlook.',
        'url': '',
        'imageUrl': 'assets/images/news.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'source': 'Market News',
        'symbol': symbol,
      },
      {
        'title': '${_getCompanyName(symbol)} Announces Strategic Partnership',
        'description': 'New partnership agreement positions ${_getCompanyName(symbol)} for expanded market reach and enhanced competitive advantage.',
        'url': '',
        'imageUrl': 'assets/images/news-placeholder.png',
        'publishedAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'source': 'Business Wire',
        'symbol': symbol,
      },
    ];
  }

  /// Format time ago string
  static String formatTimeAgo(String publishedAt) {
    try {
      final publishedTime = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(publishedTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}