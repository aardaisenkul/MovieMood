import Foundation
import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var options = FilterOptions()
    @Published var currentStep: Int = 0

    let totalSteps = 6

    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation { currentStep += 1 }
        }
    }
    func previousStep() {
        if currentStep > 0 {
            withAnimation { currentStep -= 1 }
        }
    }
    
    // Helper functions
    func resetFilters() {
        options = FilterOptions()
    }
    
    func setReleaseAfter(year: Int) {
        options.releaseAfter = "\(year)-01-01"
    }
    
    func setReleaseAfter(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        options.releaseAfter = formatter.string(from: date)
    }

    // --- Automatic option extractors (now using API data) ---
    func allGenres(from movieListVM: MovieListViewModel) -> [String] {
        return movieListVM.availableGenres.sorted()
    }
    
    func allCountries(from movieListVM: MovieListViewModel) -> [String] {
        return movieListVM.availableCountries.sorted()
    }
    
    func allLanguages(from movieListVM: MovieListViewModel) -> [String] {
        return movieListVM.availableLanguages.sorted()
    }
    
    func allCompanies(from movieListVM: MovieListViewModel) -> [String] {
        return movieListVM.availableCompanies.sorted()
    }
} 