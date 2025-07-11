import Foundation

// API Response Models
struct APIResponse<T: Decodable>: Decodable {
    let data: T
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int

    private enum CodingKeys: String, CodingKey {
        case data, result, total, page, limit, totalPages = "totalPages", total_page
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let d = try? container.decode(T.self, forKey: .data) {
            data = d
        } else if let r = try? container.decode(T.self, forKey: .result) {
            data = r
        } else {
            data = [] as! T
        }
        total = (try? container.decodeIfPresent(Int.self, forKey: .total)) ?? 0
        page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? 1
        limit = (try? container.decodeIfPresent(Int.self, forKey: .limit)) ?? 10
        totalPages = (try? container.decodeIfPresent(Int.self, forKey: .totalPages)) ?? (try? container.decodeIfPresent(Int.self, forKey: .total_page)) ?? 1
    }
}

// Parameters API Response
struct ParametersResponse: Decodable {
    let genres: GenresResponse
    let companies: CompaniesResponse
    let languages: LanguagesResponse
}

struct GenresResponse: Decodable {
    let Genres: [String]
}

struct CompaniesResponse: Decodable {
    let Countries: [String]
}

struct LanguagesResponse: Decodable {
    let Languages: [String]
}

struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let language: String
    let original_title: String
    let overview: String
    let release_date: String
    let runtime: Int
    let tagline: String
    let vote_average: Double
    let vote_count: Int
    let genres: [Genre]
    let production_companies: [ProductionCompany]
    let production_countries: [ProductionCountry]
    var cast: [CastMember]?
    var posterPath: String? = nil // TMDb poster path
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500" + path)
    }

    struct Genre: Decodable, Hashable {
        let id: Int
        let name: String
    }
    struct ProductionCompany: Decodable {
        let id: Int
        let name: String
    }
    struct ProductionCountry: Decodable, Hashable {
        let code: String
        let name: String
    }
    struct CastMember: Decodable, Hashable {
        let id: Int
        let name: String
        let character: String
        let order: Int
        var profilePath: String? = nil
        var profileURL: URL? {
            guard let path = profilePath else { return nil }
            return URL(string: "https://image.tmdb.org/t/p/w185" + path)
        }
    }
} 
