import Foundation

struct FilterOptions {
    var selectedGenres: Set<String> = [] // Changed from Movie.Genre to String
    var releaseAfter: String = "" // yyyy-mm-dd format
    var minRating: Double = 5.0
    var maxRuntime: Int = 180
    var selectedCountries: Set<String> = [] // Changed from Movie.ProductionCountry to String
    var selectedLanguage: String = ""
    var title: String = ""
    var minVoteCount: Int = 0
    var selectedCompanies: Set<String> = [] // New field for companies
    var selectedCasts: Set<String> = [] // New field for casts
    var page: Int = 1
    var limit: Int = 10
} 