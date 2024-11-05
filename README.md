# iOS Test Assignment Application

## Overview
This project is a test assignment that demonstrates a basic iOS application built using UIKit. It handles user registration, data fetching via GET and POST requests, and displays data in a user-friendly interface.

## Features
- User registration form with validation and POST request handling.
- Display and pagination of users fetched from the API.
- Custom fonts and adaptive UI elements.
- Offline mode handling with appropriate user feedback.

## Installation and Setup
1. Clone the repository from GitHub:
   ```bash
   git clone https://github.com/yourusername/your-repo.git
   ```
2. Open the project in Xcode.
3. Build and run the project on a real device or simulator.

## Dependencies
- This project does not use external libraries. All functionality is implemented with native iOS tools and APIs.

## Configuration
- Ensure that you have access to the API by modifying the `Base URL` if necessary in `NetworkManager`.

## Troubleshooting
- **Network Errors**: Ensure that your device has an active internet connection.
- **Image Loading**: If images do not load, check if the URL for images is valid.

## Known Issues
- Occasional slow image loading due to external API response time.
- Potential compatibility issues on older iOS versions.

## External APIs
- The app interacts with the `https://frontend-test-assignment-api.abz.agency/api/v1/` API to handle user registration and fetching.


