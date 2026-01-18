# Galaxy Keyboard

A custom iOS keyboard app featuring extended symbols and numbers, designed with privacy and simplicity in mind.

## Features

### Keyboard Layouts
- **QWERTY Layout**: Standard letter keyboard with shift and caps lock support
- **Number Row**: Always accessible number keys (1-9, 0)
- **Symbol Mode**: Extended punctuation and special characters
- **Extended Symbols**: Additional Unicode symbols and currency characters

### Key Highlights
- 🌐 **Globe Key**: Always visible for easy keyboard switching (AppStore compliant)
- ⚡ **No Full Access Required**: Works without special permissions
- 🎨 **Dark Mode Support**: Automatically adapts to system appearance
- 🔒 **Complete Privacy**: No data collection or network access

## Privacy & Security

Galaxy Keyboard is built with privacy as the top priority:

- ✅ **No Data Collection**: Zero personal information collected
- ✅ **Local Processing**: All functionality runs entirely on your device
- ✅ **No Network Access**: No internet connections or data transmission
- ✅ **No Analytics**: No tracking, crash reporting, or telemetry
- ✅ **No Third-Party Services**: Built using only standard iOS frameworks

## Installation & Setup

1. **Install the app** from the App Store
2. **Open Settings** → General → Keyboard → Keyboards
3. **Add New Keyboard** → Select "GalaxyKeyboard"
4. **Optional**: Enable "Full Access" for enhanced performance
5. **Test**: Use the built-in test area in the app

## Usage

- Tap the **🌐 globe button** to switch between keyboards
- Use **⇧ shift** for uppercase letters (double-tap for caps lock)
- Toggle between **ABC** and **!#1** for letters/symbols
- Access extended symbols with **1/2** and **2/2** modes

## Technical Details

### Platform Support
- iOS 14.0+
- iPhone and iPad compatible
- Supports both Light and Dark mode

### Architecture
- Built with SwiftUI and UIKit
- Custom UIInputViewController implementation
- No external dependencies

### App Store Compliance
- ✅ Globe/Next Key requirement satisfied
- ✅ Privacy policy included in app
- ✅ No special permissions required
- ✅ Full keyboard functionality without Full Access

## Development

### Project Structure
```
GalaxyKyabord/
├── GalaxyKeyboard/           # Main app target
│   ├── ContentView.swift     # TabView with Home and Privacy
│   └── GalaxyKeyboardApp.swift
├── Keyboard/                 # Keyboard extension
│   ├── KeyboardViewController.swift  # Main keyboard implementation
│   └── Info.plist           # Extension configuration
└── README.md
```

### Key Files
- **KeyboardViewController.swift**: Core keyboard functionality and layouts
- **ContentView.swift**: App UI with setup instructions and privacy policy
- **Info.plist**: Keyboard extension configuration (RequestsOpenAccess: false)

## License

This project is available for personal and educational use.

## Support

For questions or support, please contact through the App Store review system.