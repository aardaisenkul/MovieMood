import Foundation

let TMDB_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1NGEzODQwMjg2NTNmMGJjNjY4N2Q4MTVkMTNhNzE5MiIsIm5iZiI6MTY0NTUzMTIwMC4zOTMsInN1YiI6IjYyMTRkMDQwMGJiMDc2MDA0MzAwMzBiMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.35evVaSEmiCsmq3gLFIaMCHf4GubpnR1lyGx8HC0-uU"

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var totalMovies: Int = 0
    
    // Available options from API
    @Published var availableGenres: [String] = []
    @Published var availableCountries: [String] = []
    @Published var availableLanguages: [String] = []
    @Published var availableCompanies: [String] = []
    
    let baseURL = "http://localhost:8000" // MAC IP ADDRESS
    
    // Request deduplication
    private var isRequestInProgress = false
    private var lastRequestURL: String = ""
    private var requestQueue: [String] = []
    private let requestQueueLock = NSLock()

    init(loadParameters: Bool = true) {
        if loadParameters {
            fetchParameters()
        }
    }

    func loadDummyMovies() {
        if let url = Bundle.main.url(forResource: "DummyMovies2", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Movie].self, from: data) {
                self.movies = decoded
            }
        }
    }

    // MARK: - Parameters API
    func fetchParameters() {
        guard let url = URL(string: "\(baseURL)/films/filter/parameters") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let parameters = try decoder.decode(ParametersResponse.self, from: data)
                    
                    self?.availableGenres = parameters.genres.Genres
                    self?.availableCountries = parameters.companies.Countries
                    self?.availableLanguages = parameters.languages.Languages
                    self?.availableCompanies = parameters.companies.Countries
                } catch {
                    // Handle error silently
                }
            }
        }
        task.resume()
    }

    // MARK: - Backend API Integration
    func fetchMoviesFromAPI(with options: FilterOptions, completion: @escaping (Result<[Movie], Error>) -> Void) {
        // Strong request deduplication
        let requestURL = "\(baseURL)/films/filter"
        
        requestQueueLock.lock()
        defer { requestQueueLock.unlock() }
        
        if isRequestInProgress {
            return
        }
        
        if requestQueue.contains(requestURL) {
            return
        }
        
        isRequestInProgress = true
        requestQueue.append(requestURL)
        lastRequestURL = requestURL
        isLoading = true
        
        var components = URLComponents(string: "\(baseURL)/films/filter")!
        var queryItems: [URLQueryItem] = []
        
        // Add API parameters
        if !options.selectedLanguage.isEmpty {
            queryItems.append(URLQueryItem(name: "language", value: options.selectedLanguage))
        }
        
        if options.maxRuntime > 0 {
            queryItems.append(URLQueryItem(name: "max_runtime", value: String(options.maxRuntime)))
        }
        
        if options.minRating > 0 {
            queryItems.append(URLQueryItem(name: "min_vote_average", value: String(format: "%.1f", options.minRating)))
        }
        
        if options.minVoteCount > 0 {
            queryItems.append(URLQueryItem(name: "min_vote_count", value: String(options.minVoteCount)))
        }
        
        if !options.releaseAfter.isEmpty {
            queryItems.append(URLQueryItem(name: "release_after", value: options.releaseAfter))
        }
        
        if !options.title.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: options.title))
        }
        
        // New parameters
        if !options.selectedGenres.isEmpty {
            for genre in options.selectedGenres {
                queryItems.append(URLQueryItem(name: "genres", value: genre))
            }
        }
        
        if !options.selectedCountries.isEmpty {
            for country in options.selectedCountries {
                queryItems.append(URLQueryItem(name: "countries", value: country))
            }
        }
        
        if !options.selectedCompanies.isEmpty {
            for company in options.selectedCompanies {
                queryItems.append(URLQueryItem(name: "companies", value: company))
            }
        }
        
        if !options.selectedCasts.isEmpty {
            for cast in options.selectedCasts {
                queryItems.append(URLQueryItem(name: "casts", value: cast))
            }
        }
        
        queryItems.append(URLQueryItem(name: "page", value: String(options.page)))
        queryItems.append(URLQueryItem(name: "limit", value: String(options.limit)))
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            isLoading = false
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        // Clear movies before new search (only for first page)
        if options.page == 1 {
            self.movies = []
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isRequestInProgress = false
                
                // Remove from queue
                self?.requestQueueLock.lock()
                if let index = self?.requestQueue.firstIndex(of: requestURL) {
                    self?.requestQueue.remove(at: index)
                }
                self?.requestQueueLock.unlock()
                
                if let error = error {
                    self?.movies = []
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -2)))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse<[Movie]>.self, from: data)
                    
                    // Update pagination information
                    self?.currentPage = apiResponse.page
                    self?.totalPages = apiResponse.totalPages
                    self?.totalMovies = apiResponse.total
                    
                    // If first page, replace movies, otherwise append
                    if options.page == 1 {
                        self?.movies = apiResponse.data
                        self?.fetchPostersForMovies(apiKey: TMDB_API_KEY) {}
                    } else {
                        self?.movies.append(contentsOf: apiResponse.data)
                        self?.fetchPostersForMovies(apiKey: TMDB_API_KEY) {}
                    }
                    
                    completion(.success(apiResponse.data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func loadNextPage(with options: FilterOptions) {
        guard currentPage < totalPages && !isLoading else { return }
        
        var nextPageOptions = options
        nextPageOptions.page = currentPage + 1
        let oldCount = movies.count
        fetchMoviesFromAPI(with: nextPageOptions) { [weak self] result in
            switch result {
            case .success(_):
                let newMovies = self?.movies.suffix(from: oldCount) ?? []
                for movie in newMovies {
                    self?.fetchPosterForMovie(movie, apiKey: TMDB_API_KEY)
                }
            case .failure(_):
                break
            }
        }
    }
    
    func refreshMovies(with options: FilterOptions) {
        var refreshOptions = options
        refreshOptions.page = 1
        
        fetchMoviesFromAPI(with: refreshOptions) { _ in
            // Handle result silently
        }
    }

    /// Fetches the poster path from TMDb for the given movie and updates the corresponding Movie in the movies array.
    func fetchPosterForMovie(_ movie: Movie, apiKey: String, completion: (() -> Void)? = nil) {
        let year = movie.release_date.prefix(4)
        TMDbService.shared.fetchPosterPath(for: movie.title, year: year, apiKey: apiKey) { [weak self] posterPath in
            DispatchQueue.main.async {
                guard let self = self else { completion?(); return }
                guard let idx = self.movies.firstIndex(where: { $0.id == movie.id }) else {
                    completion?(); return }
                var updatedMovie = self.movies[idx]
                updatedMovie.posterPath = posterPath
                self.movies[idx] = updatedMovie
                completion?()
            }
        }
    }

    /// Fetches posters for the first 10 movies from TMDb in SERIAL (sequential) order and updates the corresponding Movies in the movies array.
    func fetchPostersForMovies(apiKey: String, completion: (() -> Void)? = nil) {
        fetchPostersForMoviesSerial(apiKey: apiKey, completion: completion)
    }

    private func fetchPostersForMoviesSerial(apiKey: String, completion: (() -> Void)? = nil) {
        let moviesToFetch = Array(movies.prefix(10))
        fetchPosterForMovieSerial(movies: moviesToFetch, index: 0, apiKey: apiKey, completion: completion)
    }

    private func fetchPosterForMovieSerial(movies: [Movie], index: Int, apiKey: String, completion: (() -> Void)?) {
        guard index < movies.count else {
            completion?()
            return
        }
        fetchPosterForMovie(movies[index], apiKey: apiKey) {
            // Wait 0.2 seconds before moving to the next
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.fetchPosterForMovieSerial(movies: movies, index: index + 1, apiKey: apiKey, completion: completion)
            }
        }
    }

    /// Fetches cast profile images for the first 10 people in SERIAL (sequential) order
    func fetchCastProfileImagesForMovie(_ movie: Movie, apiKey: String, completion: @escaping () -> Void) {
        fetchCastProfileImagesForMovieSerial(movie, apiKey: apiKey, completion: completion)
    }

    private func fetchCastProfileImagesForMovieSerial(_ movie: Movie, apiKey: String, completion: @escaping () -> Void) {
        guard let movieIdx = movies.firstIndex(where: { $0.id == movie.id }) else { completion(); return }
        guard var castMembers = movies[movieIdx].cast else { completion(); return }
        let castToFetch = Array(castMembers.prefix(10))
        fetchProfileForCastSerial(castMembers: castToFetch, allCast: castMembers, index: 0, apiKey: apiKey, movieIdx: movieIdx, completion: completion)
    }

    private func fetchProfileForCastSerial(castMembers: [Movie.CastMember], allCast: [Movie.CastMember], index: Int, apiKey: String, movieIdx: Int, completion: @escaping () -> Void) {
        var updatedCast = allCast
        guard index < castMembers.count else {
            // When all cast is updated, update the Movie
            guard movies.indices.contains(movieIdx) else {
                completion()
                return
            }
            var updatedMovie = movies[movieIdx]
            updatedMovie.cast = updatedCast
            movies[movieIdx] = updatedMovie
            completion()
            return
        }
        let cast = castMembers[index]
        TMDbService.shared.fetchProfilePath(for: cast.id, apiKey: apiKey) { profilePath in
            DispatchQueue.main.async {
                if let idx = updatedCast.firstIndex(where: { $0.id == cast.id }) {
                    updatedCast[idx].profilePath = profilePath
                }
                // Wait 0.2 seconds before moving to the next
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.fetchProfileForCastSerial(castMembers: castMembers, allCast: updatedCast, index: index + 1, apiKey: apiKey, movieIdx: movieIdx, completion: completion)
                }
            }
        }
    }

    /// Fetches movies played by a specific actor
    func fetchMoviesByCast(castName: String, page: Int = 1, completion: ((Result<[Movie], Error>) -> Void)? = nil) {
        // Strong request deduplication
        let requestURL = "\(baseURL)/films/cast?cast=\(castName)&page=\(page)"
        
        requestQueueLock.lock()
        defer { requestQueueLock.unlock() }
        
        if isRequestInProgress {
            return
        }
        
        if requestQueue.contains(requestURL) {
            return
        }
        
        isRequestInProgress = true
        requestQueue.append(requestURL)
        lastRequestURL = requestURL
        isLoading = true
        
        var components = URLComponents(string: "\(baseURL)/films/cast")!
        var queryItems: [URLQueryItem] = []
        
        // Cast parameter
        queryItems.append(URLQueryItem(name: "cast", value: castName))
        
        // Pagination parameters
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "limit", value: String(10)))
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            isLoading = false
            completion?(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        // Clear movies before new search (only for first page)
        if page == 1 {
            self.movies = []
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isRequestInProgress = false
                
                // Remove from queue
                self?.requestQueueLock.lock()
                if let index = self?.requestQueue.firstIndex(of: requestURL) {
                    self?.requestQueue.remove(at: index)
                }
                self?.requestQueueLock.unlock()
                
                if let error = error {
                    self?.movies = []
                    completion?(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion?(.failure(NSError(domain: "No data", code: -2)))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse<[Movie]>.self, from: data)
                    
                    // Update pagination information
                    self?.currentPage = apiResponse.page
                    self?.totalPages = apiResponse.totalPages
                    self?.totalMovies = apiResponse.total
                    
                    // If first page, replace movies, otherwise append
                    if page == 1 {
                        self?.movies = apiResponse.data
                        self?.fetchPostersForMovies(apiKey: TMDB_API_KEY) {}
                    } else {
                        self?.movies.append(contentsOf: apiResponse.data)
                        self?.fetchPostersForMovies(apiKey: TMDB_API_KEY) {}
                    }
                    
                    completion?(.success(apiResponse.data))
                } catch {
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
} 
