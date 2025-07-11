import Foundation

class TMDbService {
    static let shared = TMDbService()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    func fetchPosterPath(for title: String, year: Substring, apiKey: String, completion: @escaping (String?) -> Void) {
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        let urlString = "https://api.themoviedb.org/3/search/movie?query=\(query)&year=\(year)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let posterPath = first["poster_path"] as? String else {
                completion(nil)
                return
            }
            completion(posterPath)
        }
        task.resume()
    }
    
    func fetchProfilePath(for personID: Int, apiKey: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://api.themoviedb.org/3/person/\(personID)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let profilePath = json["profile_path"] as? String else {
                completion(nil)
                return
            }
            completion(profilePath)
        }
        task.resume()
    }
} 