# Libgen Scraper

A Dart package for scraping book information and download links from Library Genesis (Libgen.gs).

[![pub package](https://img.shields.io/pub/v/libgen_scraper.svg)](https://pub.dev/packages/libgen_scraper) ![license](https://img.shields.io/github/license/ShalmonAnandas/libgen_scraper)

## Features

- Search for books on Libgen.gs
- Retrieve detailed information about books
- Get download links for books

## Getting started

Add `libgen_scraper` to your `pubspec.yaml` file:

```yaml
dependencies:
  libgen_scraper: ^1.0.0
```

Then run `dart pub get` or `flutter pub get` to install the package.

## Usage

Here's a simple example of how to use the Libgen Scraper package:

```dart
import 'package:libgen_scraper/libgen_scraper.dart';

void main() async {
  LibgenScraper libgenScraper = LibgenScraper();
  
  // Search for books
  List results = await libgenScraper.getSearchResults("Camera Shy");

  // Get download link for the first result
  final downloadLink = await libgenScraper.getDownloadLinks(results.first["download_links"]);

  print(downloadLink);
}
```

## API Reference

### `LibgenScraper`

The main class for interacting with Libgen.gs.

#### Methods

- `Future<List> getSearchResults(String query)`
  
  Searches Libgen.gs for books matching the given query.

- `Future<String> getDownloadLinks(String downloadUrl)`
  
  Retrieves the download link for a specific book.

## Additional Information

### Disclaimer

This package is for educational purposes only. Make sure you comply with copyright laws and Libgen's terms of service when using this package.

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
