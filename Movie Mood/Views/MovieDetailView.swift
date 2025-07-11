import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    var viewModel: MovieListViewModel? = nil
    @EnvironmentObject var movieListVM: MovieListViewModel
    @EnvironmentObject var filterVM: FilterViewModel
    @State private var didLoadCastImages = false
    @State private var selectedCast: String? = nil
    @State private var navigateToCast = false
    @State private var castVM: CastListViewModel? = nil
    let TMDB_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1NGEzODQwMjg2NTNmMGJjNjY4N2Q4MTVkMTNhNzE5MiIsIm5iZiI6MTY0NTUzMTIwMC4zOTMsInN1YiI6IjYyMTRkMDQwMGJiMDc2MDA0MzAwMzBiMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.35evVaSEmiCsmq3gLFIaMCHf4GubpnR1lyGx8HC0-uU"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 20) {
                    if let url = movie.posterURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.15)
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                        .shadow(radius: 6)
                    } else {
                        Image("dummy_movie")
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(width: 120, height: 180)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title.bold())
                        if !movie.tagline.isEmpty {
                            Text(movie.tagline)
                                .font(.title3.italic())
                                .foregroundColor(.secondary)
                        }
                        // Country & Language
                        HStack(spacing: 12) {
                            if !movie.production_countries.isEmpty {
                                Label("\(movie.production_countries.map { $0.name }.joined(separator: ", "))", systemImage: "globe")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Label(movie.language.uppercased(), systemImage: "character.book.closed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Rating, Length, Year
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Rating: \(String(format: "%.1f", movie.vote_average))", systemImage: "star.fill")
                                .font(.body.bold())
                                .foregroundColor(.yellow)
                            Label("Length: \(movie.runtime) min", systemImage: "clock")
                                .font(.body.bold())
                                .foregroundColor(.blue)
                            Label("Year: \(movie.release_date.prefix(4))", systemImage: "calendar")
                                .font(.body.bold())
                                .foregroundColor(.purple)
                        }
                    }
                }
                // Genres badge
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(movie.genres, id: \.id) { genre in
                            Text(genre.name)
                                .font(.headline.bold())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(genreColor(for: genre.name).opacity(0.18))
                                .foregroundColor(genreColor(for: genre.name))
                                .cornerRadius(12)
                        }
                    }
                }
                Divider()
                Text("Cast")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(movie.cast?.prefix(10) ?? [], id: \.id) { cast in
                            NavigationLink(
                                destination: {
                                    let vm = CastListViewModel()
                                    vm.fetchMoviesByCast(castName: cast.name)
                                    return CastListView(castName: cast.name, viewModel: vm)
                                        .environmentObject(movieListVM)
                                        .environmentObject(filterVM)
                                }()
                            ) {
                                VStack(alignment: .center, spacing: 8) {
                                    if let url = cast.profileURL {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .foregroundColor(.gray.opacity(0.3))
                                        }
                                        .frame(width: 80, height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(radius: 6)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 80, height: 110)
                                            .foregroundColor(.gray.opacity(0.3))
                                            .background(Color.gray.opacity(0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .shadow(radius: 6)
                                    }
                                    Spacer(minLength: 0)
                                    VStack(spacing: 2) {
                                        Text(cast.name)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: 90)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.7)
                                            .truncationMode(.tail)
                                        Text(cast.character)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: 90)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.7)
                                            .truncationMode(.tail)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(width: 100, height: 200)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(18)
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }
                Divider()
                Text("Overview")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                Text(movie.overview)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                if !movie.production_companies.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Production Companies")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(movie.production_companies, id: \.id) { company in
                                    Text(company.name)
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.15))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                if let imdbQuery = movie.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let imdbURL = URL(string: "https://www.imdb.com/find?q=\(imdbQuery)") {
                    Link(destination: imdbURL) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                            Text("Search on IMDb")
                                .font(.headline)
                        }
                        .padding(10)
                        .background(Color.yellow.opacity(0.18))
                        .foregroundColor(.yellow)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                }
            }
            .padding()
        }
        .onAppear {
            let vm = viewModel ?? movieListVM
            vm.fetchPosterForMovie(movie, apiKey: TMDB_API_KEY) {}
            vm.fetchCastProfileImagesForMovie(movie, apiKey: TMDB_API_KEY) {}
        }
        .background(
            Group {
                if let castName = selectedCast, let castVM = castVM {
                    NavigationLink(
                        destination: CastListView(castName: castName, viewModel: castVM),
                        isActive: $navigateToCast
                    ) {
                        EmptyView()
                    }
                }
            }
        )
    }

    func genreColor(for name: String) -> Color {
        switch name.lowercased() {
        case "action": return .red
        case "adventure": return .green
        case "comedy": return .yellow
        case "drama": return .orange
        case "science fiction": return .blue
        case "fantasy": return .purple
        case "horror": return .black
        case "romance": return .pink
        case "animation": return .mint
        case "thriller": return .indigo
        default: return .accentColor
        }
    }
} 
