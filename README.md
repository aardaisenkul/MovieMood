# Movie Mood

Movie Mood is a modern, user-friendly movie recommendation app built with Swift and SwiftUI. It allows users to discover movies based on their preferences, filter by various criteria, and explore detailed information about each film, including cast and posters fetched from TMDb.

## 🎥 App Preview
<img src="app_video.gif" width="400"/>

## 🎬 What Does Movie Mood Do?

- Recommends movies based on user-selected filters (genre, year, rating, runtime, country, language, etc.)
- Fetches movie data from a custom backend API (provided separately, Dockerized)
- Displays movie posters and cast images using The Movie Database (TMDb) API
- Allows users to view detailed information about each movie
- Users can tap on a cast member to see all movies that actor/actress has played in
- Responsive, visually appealing UI with smooth navigation
- **NEW**: Push navigation for cast-based movie lists with dedicated ViewModels

## 🛠️ Technologies Used

- **Swift** (programming language)
- **SwiftUI** (UI framework)
- **MVVM** (Model-View-ViewModel architecture)
- **TMDb API** (for posters and cast images)
- **Custom Backend API** (for movie data, must be running via Docker)

## 📱 Main Views & Components

- **SplashScreenView**: Animated splash screen with Lottie animations
- **ContentView**: Main entry point, manages navigation and state
- **ConversationView**: Step-by-step filter selection (genre, year, rating, runtime, country, language)
- **MovieListView**: Displays a list of recommended movies (with posters)
- **MovieDetailView**: Shows detailed info, poster, genres, cast (with images), overview, production companies, IMDb link
- **CastListView**: Dedicated view for displaying movies by a specific cast member
- **CastListViewModel**: Separate ViewModel for cast-based movie lists
- **Reusable Components**: ChipView, WrapHStack, etc.

## 🗂️ Model & API Integration

- **Model**: Movie, Genre, ProductionCompany, ProductionCountry, CastMember, etc. (see `Models/Models.swift`)
- **API**: Fetches movies and filter parameters from backend (`/films/filter`, `/films/filter/parameters`)
- **TMDb**: Used for fetching poster and cast images (not included in backend)
- **Pagination**: Supported for large result sets
- **Error Handling**: Automatic fallback to dummy data if backend is unavailable

## 🌐 Why TMDb?

- TMDb provides high-quality, up-to-date movie posters and cast images
- Ensures a visually rich and engaging user experience
- TMDb is widely used and reliable for movie metadata

## 🎯 Project Goals

- Provide a seamless, interactive movie discovery experience
- Combine a custom backend with a modern iOS frontend
- Enable users to filter and explore movies in detail
- Demonstrate best practices in SwiftUI and MVVM
- Clean, production-ready code with proper error handling

## 🚀 How to Run

1. **Clone this repository**
2. **Start the backend** (your friend will provide Docker instructions)
3. **Open `Movie Mood.xcodeproj` in Xcode**
4. Make sure your backend is running and accessible (update the IP in `MovieListViewModel.swift` if needed)
5. **Run the app on a real iOS device** (recommended; for simulator, see notes below)
6. Update the `baseURL` in `MovieListViewModel.swift` to match your Mac's IP address
7. Enjoy discovering movies!

### Prerequisites

- Xcode 14+
- iOS 16+ device (recommended)
- Backend API running (Docker)
- TMDb API key (already included in the project)

### Notes

- **Simulators** may have network issues; real device is recommended
- If running on a real device, ensure your backend is accessible via your Mac's local IP
- **Fallback**: If the backend is unavailable, the app will automatically load dummy data

## 🔧 Recent Updates

- **Cast Navigation**: Replaced sheet-based navigation with push navigation for better UX
- **Separate ViewModels**: Cast-based movie lists now use dedicated ViewModels to prevent state conflicts
- **Code Cleanup**: Removed debug prints and unnecessary code for production readiness
- **Error Handling**: Improved error handling with silent fallbacks
- **Performance**: Optimized poster and cast image fetching with sequential requests

## 👥 Credits

- **Backend API**: Developed by [İdrishan Parlayan - Elif Meric]
- **Frontend (this app)**: Developed by [Ali Arda Isenkul - Sertac Gokkaya]
- **Movie data & images**: [TMDb](https://www.themoviedb.org/)

---

For any questions or issues, please open an issue or contact the maintainer.
