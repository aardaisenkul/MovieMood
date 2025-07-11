//
//  ContentView.swift
//  Movie Mood
//
//  Created by Ali Arda İsenkul on 03.07.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var filterVM = FilterViewModel()
    @StateObject var movieListVM = MovieListViewModel()
    @State private var isLoading = false
    @State private var showingResults = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            if isLoading {
                VStack(spacing: 24) {
                    LottieView(name: "loading_animation", loopMode: .loop)
                        .frame(width: 240, height: 240)
                    Text("Preparing movies...")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            } else if showingResults {
                MovieListView(
                    castName: nil,
                    viewModel: movieListVM,
                    onClose: {
                        filterVM.resetFilters()
                        movieListVM.movies = []
                        filterVM.currentStep = 0
                        showingResults = false
                    }
                )
                .environmentObject(filterVM)
            } else {
                ConversationView(
                    filterVM: filterVM,
                    onFinish: {
                        isLoading = true
                        // Load movies from backend API
                        movieListVM.fetchMoviesFromAPI(with: filterVM.options) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(_):
                                    showingResults = true
                                case .failure(_):
                                    // Load dummy data in case of error
                                    movieListVM.loadDummyMovies()
                                    showingResults = true
                                }
                            }
                        }
                    }
                )
                .environmentObject(movieListVM)
            }
        }
    }
}

#Preview {
    ContentView()
}
