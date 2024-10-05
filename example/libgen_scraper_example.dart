import 'package:libgen_scraper/libgen_scraper.dart';

void main() async {
  LibgenScraper libgenScraper = LibgenScraper();
  List results = await libgenScraper.getSearchResults("Camera Shy");

  final downloadLink =
      await libgenScraper.getDownloadLinks(results.first["download_links"]);

  print(downloadLink);
}
