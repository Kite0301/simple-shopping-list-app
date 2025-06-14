# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a Flutter application. Common development commands:

- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis
- `flutter clean` - Clean build artifacts

## Architecture Overview

This is a simple shopping list Flutter app with a Provider pattern for state management:

### Core Architecture
- **Provider Pattern**: Uses `ChangeNotifierProvider` with `ShoppingListProvider` as the main state manager
- **Local Storage**: Persists data using SharedPreferences via `StorageService`
- **Multi-List Support**: Tab-based interface for managing multiple shopping lists

### Key Components
- `ShoppingListProvider` (lib/providers/): Central state management for all shopping lists and items
- `StorageService` (lib/services/): Handles JSON serialization and SharedPreferences persistence  
- `ShoppingList` & `ShoppingItem` (lib/models/): Core data models with JSON conversion
- `ShoppingListScreen` (lib/screens/): Main UI with tab navigation between lists

### Data Flow
1. App initializes `ShoppingListProvider` which loads data via `StorageService`
2. UI components consume provider state and trigger provider methods
3. Provider methods update in-memory state and persist changes via `StorageService`
4. Items are automatically sorted with unpurchased items first, then purchased

### Japanese Language
The app uses Japanese text by default (e.g., default list name "スーパー"). Consider this when adding new features.