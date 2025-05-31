# Golden Tests Documentation

## Overview
This project now includes comprehensive golden tests for visual regression testing of the Flutter cocktail app's UI components. Golden tests capture rendered widget screenshots and compare them against baseline images to detect visual changes.

## Test Coverage

### CocktailCard Widget Tests (4 tests)
- **Easy difficulty cocktail**: Tests the display of an easy cocktail card
- **Hard difficulty cocktail**: Tests the display of a hard cocktail card  
- **Cocktail without description**: Tests the card layout when description is null
- **Basic functionality test**: Verifies text content appears correctly

### CocktailListScreen Widget Tests (3 tests)
- **Empty state**: Tests the screen when no cocktails are available
- **Loading state**: Tests the loading indicator display
- **Loaded state with cocktails**: Tests the list with multiple cocktail cards

### CocktailDetailScreen Widget Tests (3 tests)
- **Easy cocktail detail**: Tests detailed view of an easy cocktail with full ingredients
- **Hard cocktail detail**: Tests detailed view of a complex cocktail with many ingredients
- **Error state**: Tests error handling when cocktail is not found

## Running Golden Tests

### Generate New Baseline Images
When UI components change or new tests are added:
```bash
flutter test test/src/feature/cocktail/widget/ --update-goldens
```

### Run Golden Tests for Validation
To verify UI components match baselines:
```bash
flutter test test/src/feature/cocktail/widget/
```

### Run Specific Test Files
```bash
# Cocktail card tests only
flutter test test/src/feature/cocktail/widget/cocktail_card_test.dart

# Cocktail list screen tests only  
flutter test test/src/feature/cocktail/widget/cocktail_list_screen_test.dart

# Cocktail detail screen tests only
flutter test test/src/feature/cocktail/widget/cocktail_detail_screen_test.dart
```

## File Structure
```
test/src/feature/cocktail/widget/
├── cocktail_card_test.dart              # Card component golden tests
├── cocktail_list_screen_test.dart       # List screen golden tests
├── cocktail_detail_screen_test.dart     # Detail screen golden tests
├── cocktail_list_screen_test.mocks.dart # Generated mock classes
└── golden/                              # Baseline images directory
    ├── cocktail_card_easy.png
    ├── cocktail_card_hard.png
    ├── cocktail_card_no_description.png
    ├── cocktail_list_empty.png
    ├── cocktail_list_loading.png
    ├── cocktail_list_loaded.png
    ├── cocktail_detail_easy.png
    ├── cocktail_detail_hard.png
    └── cocktail_detail_error.png
```

## Key Features

### Mock Usage
- Uses mockito for mocking `CocktailRepository`
- Tests various data scenarios with controlled mock responses
- Proper dependency injection through `DependenciesScope`

### State Coverage
- Loading states with spinners
- Empty states with appropriate messaging
- Error states with error handling
- Loaded states with real data
- Different difficulty levels and content variations

### Test Data
- Realistic cocktail recipes with ingredients
- Proper enum usage for difficulty levels
- Date/time handling for creation/update timestamps
- Optional ingredient support

## Maintenance Guidelines

### When to Update Golden Images
1. **Intentional UI changes**: After modifying component styling, layout, or colors
2. **Theme updates**: When app theme or color scheme changes
3. **Font changes**: After updating typography or font families
4. **New features**: When adding new UI elements to existing components

### When Tests Should Fail
Golden tests should fail and require investigation when:
1. **Unintentional visual changes**: Accidental styling modifications
2. **Dependency updates**: UI library updates that change appearance
3. **Platform differences**: Rendering differences across Flutter versions

### Best Practices
1. **Review changes carefully**: Always examine baseline image diffs before updating
2. **Test on multiple platforms**: Verify consistency across iOS/Android if needed
3. **Keep tests focused**: Each test should cover a specific UI state or scenario
4. **Use descriptive names**: Test names should clearly indicate what's being tested
5. **Mock external dependencies**: Ensure tests are isolated and deterministic

## Dependencies
- `flutter_test`: Flutter testing framework
- `mockito`: Mock object generation
- `build_runner`: Code generation for mocks

## Continuous Integration
These tests can be integrated into CI/CD pipelines to automatically detect visual regressions. In CI, run:
```bash
flutter test test/src/feature/cocktail/widget/
```

If tests fail due to visual changes, the CI should fail and require manual review before updating baselines.
