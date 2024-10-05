import 'package:libgen_scraper/libgen_scraper.dart';
import 'package:test/test.dart';

void main() {
  group('LibgenScraperTest', () {
    final LibgenScraper libgenScraper = LibgenScraper();

    test('Scraper Test', () async {
      final scrapingResults =
          await libgenScraper.getSearchResults("Harry Potter");
      expect(scrapingResults.runtimeType, List<Map<String, String>>);
      expect(scrapingResults.length, greaterThan(0));

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
    });

    test('Download Links Test', () async {
      final downloadLinks = await libgenScraper.getDownloadLinks(
          "http://library.lol/fiction/94e00014a9d854d542505e2336a8726e");

      expect(downloadLinks.keys, contains("GET"));
      expect(downloadLinks["GET"], isNotEmpty);
    });
  });
}
