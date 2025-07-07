import 'package:libgen_scraper/libgen_scraper.dart';
import 'package:libgen_scraper/src/api_client.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;

import 'libgen_scraper_test.mocks.dart';

@GenerateMocks([http_io.IOClient])
void main() {
  group('APIClient Tests', () {
    late APIClient apiClient;
    late MockIOClient mockIOClient;

    setUp(() {
      apiClient = APIClient();
      mockIOClient = MockIOClient();
    });

    test('getRequest should return successful response', () async {
      // Arrange
      const testUrl = 'https://example.com';
      const responseBody = 'Test response';
      when(mockIOClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await apiClient.getRequest(
        ioClient: mockIOClient,
        url: testUrl,
      );

      // Assert
      expect(response.statusCode, equals(200));
      expect(response.body, equals(responseBody));
      verify(mockIOClient.close()).called(1);
    });

    test('getRequest should handle HTTP errors gracefully', () async {
      // Arrange
      const testUrl = 'https://example.com';
      when(mockIOClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      // Act
      final response = await apiClient.getRequest(
        ioClient: mockIOClient,
        url: testUrl,
      );

      // Assert
      expect(response.statusCode, equals(500));
      expect(response.body, equals('HTTP ERROR'));
      verify(mockIOClient.close()).called(1);
    });

    test('getRequest should pass headers correctly', () async {
      // Arrange
      const testUrl = 'https://example.com';
      const headers = {'User-Agent': 'Test'};
      when(mockIOClient.get(Uri.parse(testUrl), headers: headers))
          .thenAnswer((_) async => http.Response('OK', 200));

      // Act
      await apiClient.getRequest(
        ioClient: mockIOClient,
        url: testUrl,
        headers: headers,
      );

      // Assert
      verify(mockIOClient.get(Uri.parse(testUrl), headers: headers)).called(1);
    });
  });

  group('LibgenScraper Tests', () {
    late LibgenScraper scraper;
    late MockIOClient mockIOClient;

    setUp(() {
      scraper = LibgenScraper();
      mockIOClient = MockIOClient();
    });

    group('getSearchResults', () {
      test('should handle empty query', () async {
        // Act & Assert
        expect(() => scraper.getSearchResults(''), throwsA(isA<Exception>()));
      });

      test('should handle query with special characters', () async {
        // Arrange
        const query = 'Test & Title';
        const mockHtml = '''
          <table class="table table-striped">
            <tbody>
              <tr>
                <td><img src="/test.jpg" /></td>
                <td></td>
                <td>Test Author</td>
                <td></td>
                <td><nobr>2023</nobr></td>
                <td>English</td>
                <td>100</td>
                <td>1MB</td>
                <td>pdf</td>
                <td><a title="Test<br>Test Title" href="#"></a></td>
                <td><a title="libgen.is" href="http://test.com"></a></td>
              </tr>
            </tbody>
          </table>
        ''';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockHtml, 200));

        // Mock the APIClient to use our mock IOClient
        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act
        final results = await scraper.getSearchResults(query);

        // Assert
        expect(results, isA<List<Map<String, String>>>());
        expect(results.length, equals(1));
        expect(results[0]['author'], equals('Test Author'));
        expect(results[0]['title'], equals('Test Title'));

        // Restore original apiClient
        scraper.apiClient = originalApiClient;
      });

      test('should handle malformed HTML', () async {
        // Arrange
        const query = 'Test Query';
        const mockHtml = '<div>No table here</div>';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockHtml, 200));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act
        final results = await scraper.getSearchResults(query);

        // Assert
        expect(results, isA<List<Map<String, String>>>());
        expect(results.length, equals(0));

        scraper.apiClient = originalApiClient;
      });

      test('should throw exception for HTTP error status', () async {
        // Arrange
        const query = 'Test Query';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Error', 404));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act & Assert
        expect(() => scraper.getSearchResults(query), throwsA(isA<Exception>()));

        scraper.apiClient = originalApiClient;
      });

      test('should properly parse all required fields', () async {
        // Arrange
        const query = 'Test Query';
        const mockHtml = '''
          <table class="table table-striped">
            <tbody>
              <tr>
                <td><img src="/test_small.jpg" /></td>
                <td></td>
                <td>John Doe</td>
                <td></td>
                <td><nobr>2023-01-01</nobr></td>
                <td>English</td>
                <td>250</td>
                <td>2.5MB</td>
                <td>epub</td>
                <td><a title="Book<br>Amazing Book Title" href="#"></a></td>
                <td><a title="libgen.is" href="http://download.link"></a></td>
              </tr>
            </tbody>
          </table>
        ''';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockHtml, 200));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act
        final results = await scraper.getSearchResults(query);

        // Assert
        expect(results, isNotEmpty);
        final result = results[0];
        expect(result['author'], equals('John Doe'));
        expect(result['title'], equals('Amazing Book Title'));
        expect(result['poster'], equals('https://libgen.gs/test.jpg'));
        expect(result['language'], equals('English'));
        expect(result['pages'], equals('250'));
        expect(result['size'], equals('2.5MB'));
        expect(result['extension'], equals('epub'));
        expect(result['release_date'], equals('2023-01-01'));
        expect(result['download_links'], equals('http://download.link'));

        scraper.apiClient = originalApiClient;
      });
    });

    group('getDownloadLinks', () {
      test('should handle valid mirror URL', () async {
        // Arrange
        const mirrorUrl = 'http://example.com/mirror';
        const mockHtml = '''
          <html>
            <body>
              <a href="http://direct.download.com">GET</a>
              <a href="http://cloudflare.com">Cloudflare</a>
              <a href="http://ipfs.io">IPFS.io</a>
            </body>
          </html>
        ''';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockHtml, 200));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act
        final downloadLinks = await scraper.getDownloadLinks(mirrorUrl);

        // Assert
        expect(downloadLinks, isA<Map<String, String>>());
        expect(downloadLinks['GET'], equals('http://direct.download.com'));
        expect(downloadLinks['Cloudflare'], equals('http://cloudflare.com'));
        expect(downloadLinks['IPFS.io'], equals('http://ipfs.io'));

        scraper.apiClient = originalApiClient;
      });

      test('should handle empty mirror page', () async {
        // Arrange
        const mirrorUrl = 'http://example.com/mirror';
        const mockHtml = '<html><body>No download links</body></html>';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockHtml, 200));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act
        final downloadLinks = await scraper.getDownloadLinks(mirrorUrl);

        // Assert
        expect(downloadLinks, isA<Map<String, String>>());
        expect(downloadLinks.isEmpty, isTrue);

        scraper.apiClient = originalApiClient;
      });

      test('should throw exception for HTTP error', () async {
        // Arrange
        const mirrorUrl = 'http://example.com/mirror';

        when(mockIOClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Error', 404));

        final originalApiClient = scraper.apiClient;
        scraper.apiClient = MockApiClientWrapper(mockIOClient);

        // Act & Assert
        expect(() => scraper.getDownloadLinks(mirrorUrl), throwsA(isA<Exception>()));

        scraper.apiClient = originalApiClient;
      });

      test('should handle invalid mirror URL', () async {
        // Arrange
        const invalidUrl = 'not-a-url';

        // Act & Assert
        expect(() => scraper.getDownloadLinks(invalidUrl), throwsA(isA<Exception>()));
      });

      test('should handle empty mirror URL', () async {
        // Act & Assert
        expect(() => scraper.getDownloadLinks(''), throwsA(isA<Exception>()));
        expect(() => scraper.getDownloadLinks('   '), throwsA(isA<Exception>()));
      });
    });
  });

  group('Integration Tests', () {
    final LibgenScraper libgenScraper = LibgenScraper();

    test('End-to-end search test (may fail if service unavailable)', () async {
      try {
        final scrapingResults = await libgenScraper.getSearchResults("Test");
        
        expect(scrapingResults, isA<List<Map<String, String>>>());
        
        if (scrapingResults.isNotEmpty) {
          for (var result in scrapingResults) {
            expect(result.keys, contains("author"));
            expect(result.keys, contains("title"));
            expect(result.keys, contains("poster"));
            expect(result.keys, contains("language"));
            expect(result.keys, contains("pages"));
            expect(result.keys, contains("size"));
            expect(result.keys, contains("extension"));
            expect(result.keys, contains("release_date"));
            expect(result.keys, contains("download_links"));
          }
        }
      } catch (e) {
        // Test passes if service is unavailable (expected in CI environments)
        expect(e, isA<Exception>());
        print('Integration test skipped due to service unavailability: $e');
      }
    }, timeout: Timeout(Duration(seconds: 30)));
  });
}

// Helper class to mock APIClient behavior
class MockApiClientWrapper extends APIClient {
  final MockIOClient mockIOClient;

  MockApiClientWrapper(this.mockIOClient);

  @override
  http_io.IOClient getApiClient() {
    return mockIOClient;
  }

  @override
  Future<http.Response> getRequest({
    required http_io.IOClient ioClient,
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      return await ioClient.get(Uri.parse(url), headers: headers);
    } catch (e) {
      return http.Response("HTTP ERROR", 500);
    } finally {
      ioClient.close();
    }
  }
}
