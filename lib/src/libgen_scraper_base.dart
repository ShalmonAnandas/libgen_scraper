import 'package:libgen_scraper/src/api_client.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class LibgenScraper {
  APIClient apiClient = APIClient();

// Function to scrape fiction from Libgen
  Future<List<Map<String, String>>> getSearchResults(String query) async {
    final url =
        'https://libgen.gs/index.php?req=${query.replaceAll(" ", "%20")}&columns%5B%5D=t&columns%5B%5D=a&topics%5B%5D=l&topics%5B%5D=f&res=100&covers=on';
    final response = await apiClient.getRequest(
        ioClient: apiClient.getApiClient(), url: url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load page");
    }

    var document = parser.parse(response.body);
    List<Map<String, String>> results = [];

    // Find table containing the data
    Element? table = document.querySelector("table.table.table-striped");
    if (table != null) {
      Element? tbody = table.querySelector("tbody");
      List<Element> rows = tbody!.querySelectorAll("tr");

      for (var row in rows) {
        // Extracting image source
        Element? imgTag = row.querySelector('td img');
        String? imgSrc = imgTag?.attributes['src'];

        // Extracting title
        Element? titleTag = row.querySelector('a[title]');
        String? title = titleTag?.attributes['title']?.split("<br>")[1];

        // Extracting author
        Element? authorTag = row.querySelectorAll('td')[2];
        String? author = authorTag.text.trim();

        // Extracting release date
        Element? releaseDateTag =
            row.querySelectorAll('td')[4].querySelector('nobr');
        String? releaseDate = releaseDateTag?.text.trim();

        // Extracting language
        Element? languageTag = row.querySelectorAll('td')[5];
        String? language = languageTag.text.trim();

        // Extracting pages, size, and extension
        String? pages = row.querySelectorAll('td')[6].text.trim();
        String? size = row.querySelectorAll('td')[7].text.trim();
        String? extension = row.querySelectorAll('td')[8].text.trim();

        // Extracting URL
        Element? urlTag = row.querySelector('a[title="libgen.is"]');
        String? downloadUrl = urlTag?.attributes['href'];

        // Create JSON-like object
        results.add({
          "author": author,
          "title": title ?? '',
          "poster": imgSrc != null
              ? 'https://libgen.gs${imgSrc.replaceAll("_small", "")}'
              : '',
          "language": language,
          "pages": pages,
          "size": size,
          "extension": extension,
          "release_date": releaseDate ?? '',
          "download_links": downloadUrl ?? '',
        });
      }
    }

    return results;
  }

// Function to extract download links from a given mirror page
  Future<Map<String, String>> getDownloadLinks(String mirror) async {
    final response = await apiClient.getRequest(
        ioClient: apiClient.getApiClient(), url: mirror);

    if (response.statusCode != 200) {
      throw Exception("Failed to load mirror page");
    }

    var document = parser.parse(response.body);
    List<String> mirrorSources = ["GET", "Cloudflare", "IPFS.io", "Infura"];
    Map<String, String> downloadLinks = {};

    // Find the download links
    document.querySelectorAll('a').forEach((link) {
      if (mirrorSources.contains(link.text)) {
        downloadLinks[link.text] = link.attributes['href']!;
      }
    });

    return downloadLinks;
  }
}
