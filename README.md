
<!--

This README describes the package. If you publish this package to pub.dev,

this README's contents appear on the landing page for your package.

  

For information about how to write a good package README, see the guide for

[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

  

For general information about developing packages, see the Dart guide for

[creating packages](https://dart.dev/guides/libraries/create-library-packages)

and the Flutter guide for

[developing packages and plugins](https://flutter.dev/developing-packages).

-->

  

A simple Libgen.gs scraper

  

## Features

  

 - Search Results scraper
 - Download Links scraper

## Usage

  

```dart

import  'package:libgen_scraper/libgen_scraper.dart';

void  main() async {
	LibgenScraper  libgenScraper  =  LibgenScraper();
	List  results  =  await  libgenScraper.getSearchResults("Camera Shy");

	final  downloadLink  = await  libgenScraper.getDownloadLinks(results.first["download_links"]);

	print(downloadLink);
}
