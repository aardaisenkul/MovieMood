import SwiftUI

struct CastListView: View {
    let castName: String
    @ObservedObject var viewModel: CastListViewModel
    @EnvironmentObject var movieListVM: MovieListViewModel
    @EnvironmentObject var filterVM: FilterViewModel

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
                    Text("Sorry, we couldn't find any movies for this cast.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie, viewModel: viewModel)
                            .environmentObject(movieListVM)
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
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Movies by \(castName)")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchMoviesByCast(castName: castName)
        }
    }
} 