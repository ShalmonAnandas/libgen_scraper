# Testing Guide

This document provides information about the test suite for the libgen_scraper package.

## Test Structure

The test suite is organized into several categories:

### 1. APIClient Tests
- Tests for the HTTP client functionality
- Mock-based tests that don't require network access
- Covers successful requests, error handling, and header passing

### 2. LibgenScraper Unit Tests

#### getSearchResults Tests
- Empty query handling
- Special character handling in queries
- Malformed HTML parsing
- HTTP error status handling
- Complete field parsing validation

#### getDownloadLinks Tests
- Valid mirror URL parsing
- Empty mirror page handling
- HTTP error handling
- Invalid URL validation

### 3. Integration Tests
- End-to-end testing with actual service calls
- Gracefully handles service unavailability
- Optional test that may be skipped in CI environments

## Running Tests

```bash
# Install dependencies
dart pub get

# Generate mock files (required for first run)
dart run build_runner build

# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage
```

## Test Dependencies

- `test`: Core testing framework
- `mockito`: Mocking framework for unit tests
- `build_runner`: Code generation for mocks

## Test Best Practices

1. **Unit tests** should not depend on external services
2. **Integration tests** should gracefully handle service unavailability
3. **Mock data** should represent realistic HTML structures
4. **Error cases** should be thoroughly tested
5. **All public methods** should have comprehensive test coverage

## Adding New Tests

When adding new functionality:

1. Add unit tests with mocked dependencies
2. Test both success and error scenarios
3. Include edge case testing
4. Update integration tests if needed
5. Regenerate mocks if new classes are added: `dart run build_runner build`

## Continuous Integration

The test suite is designed to work in CI environments where external services may not be available. Integration tests will pass even if the libgen service is unreachable.