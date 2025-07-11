import SwiftUI

struct MovieListView: View {
    var castName: String? = nil
    @ObservedObject var viewModel: MovieListViewModel
    var onClose: (() -> Void)? = nil
    @EnvironmentObject var filterVM: FilterViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var didFetch = false
    @State private var viewAppeared = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading movies...")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.movies.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "film")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    Text("Sorry, we couldn't find any movies for your criteria.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)
                            .environmentObject(viewModel)
                            .environmentObject(filterVM)
                        ) {
                            HStack(spacing: 16) {
                                if let url = movie.posterURL {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.15)
                                    }
                                    .aspectRatio(2/3, contentMode: .fit)
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                } else {
                                    Image("dummy_movie")
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .frame(width: 60, height: 90)
                                        .cornerRadius(8)
                                        .shadow(radius: 3)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(movie.title)
                                        .font(.headline)
                                    Text(movie.tagline)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    HStack(spacing: 4) {
                                        Label(String(format: "%.1f", movie.vote_average), systemImage: "star.fill")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.yellow)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Pagination indicator
                    if viewModel.currentPage < viewModel.totalPages {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                Button("Load More") {
                                    viewModel.loadNextPage(with: filterVM.options)
                                }
                                .padding()
                            }
                            Spacer()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(castName != nil ? "Movies by \(castName!)" : "Recommended Movies")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshMovies(with: filterVM.options)
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onClose?()
                    if castName != nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .onAppear {
            if !viewAppeared {
                viewAppeared = true
                didFetch = false
            }
            
            if !didFetch {
                didFetch = true
            }
        }
        .onDisappear {
            viewAppeared = false
            didFetch = false
        }
        .refreshable {
            viewModel.refreshMovies(with: filterVM.options)
        }
    }
} 
