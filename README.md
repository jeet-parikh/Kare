# ProKare

A native iOS health and wellness tracking application that helps users monitor personal health metrics, visualize trends, and share progress with friends for accountability.

![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5-orange.svg)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow.svg)

## Features

### Health Tracking
- Track customizable health metrics (blood pressure, custom fields, yes/no items, text entries)
- Date-based data entry with calendar integration
- Flexible data types to accommodate various health measurements

### Data Visualization
- View historical trends and analytics
- Detailed trend breakdowns for each tracked metric
- Add data for custom dates

### Social Accountability
- Connect with friends to share health progress
- Send and receive friend requests
- View friends' health data and trends (with their permission)

### Authentication & Security
- Email/password authentication
- Google Sign-In integration
- Biometric authentication (Face ID / Touch ID)
- Secure password reset flow

### Notifications
- Push notifications via Firebase Cloud Messaging
- Customizable notification times for health reminders
- In-app notification banners

## Tech Stack

- **Language:** Swift 5
- **Platform:** iOS 13.0+
- **UI Framework:** UIKit with Storyboards
- **Backend:** Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging
- **Local Storage:** Core Data
- **Dependency Management:** CocoaPods

## Dependencies

| Library | Purpose |
|---------|---------|
| Firebase Suite | Authentication, database, storage, push notifications |
| SCLAlertView | Custom alert dialogs |
| AnimatedField | Animated text input fields |
| IQKeyboardManagerSwift | Automatic keyboard handling |
| NotificationBannerSwift | In-app notification banners |
| SkeletonView | Loading skeleton animations |
| iOSDropDown | Dropdown menu components |
| EmptyDataSet-Swift | Empty state UI handling |

## Project Structure

```
Kare/
├── Authentication/     # Login, signup, password reset, biometrics
├── Home/              # Main dashboard and health tracking
│   ├── Item Cells/    # Collection view cells for different data types
│   ├── Add Items/     # Add new health metrics
│   ├── Manage Items/  # Edit and organize tracked items
│   ├── Customize Items/  # Notification and display settings
│   └── View User/     # View friends' health data
├── User/              # Profile and friend management
├── Trends/            # Data visualization and analytics
├── Models/            # Data models and Firebase utilities
└── Assets.xcassets/   # Images, icons, and colors
```

## Getting Started

### Prerequisites
- Xcode 12.0+
- iOS 13.0+ device or simulator
- CocoaPods installed

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/ProKare.git
   cd ProKare
   ```

2. Install dependencies
   ```bash
   pod install
   ```

3. Configure Firebase
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add an iOS app with bundle ID `com.parikhbros.ProKare`
   - Download `GoogleService-Info.plist` and replace the existing one
   - Enable Authentication (Email/Password and Google)
   - Create a Firestore database
   - Set up Cloud Storage

4. Open the workspace
   ```bash
   open ProKare.xcworkspace
   ```

5. Build and run on your device or simulator

## Screenshots

*Coming soon*

## License

This project is available for portfolio demonstration purposes.

## Authors

- **Jeet Parikh**
- **Niraj Parikh**
