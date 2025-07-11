import Foundation

class CastListViewModel: MovieListViewModel {
    func fetchMoviesByCast(castName: String, page: Int = 1) {
        isLoading = true
        var components = URLComponents(string: "\(baseURL)/films/cast")!
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "cast", value: castName))
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "limit", value: String(10)))
        components.queryItems = queryItems
        guard let url = components.url else {
            isLoading = false
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.movies = []
                    return
                }
                guard let data = data else {
                    self?.movies = []
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse<[Movie]>.self, from: data)
                    self?.movies = apiResponse.data
                    self?.fetchPostersForMovies(apiKey: TMDB_API_KEY)
                } catch {
                    self?.movies = []
                }
            }
        }
        task.resume()
    }
} 
