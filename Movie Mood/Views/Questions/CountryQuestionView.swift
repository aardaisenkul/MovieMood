import SwiftUI

struct CountryQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var movieListVM: MovieListViewModel

    var body: some View {
        let allCountries = filterVM.allCountries(from: movieListVM)
        let isAnySelected = !filterVM.options.selectedCountries.isEmpty

        VStack(alignment: .leading, spacing: 16) {
            Text("Which countries?")
                .font(.title2.bold())
            ScrollView {
                WrapHStack(["Any"] + allCountries, id: \.self) { country in
                    ChipView(
                        text: country,
                        isSelected: country == "Any" ? !isAnySelected : filterVM.options.selectedCountries.contains(country)
                    ) {
                        if country == "Any" {
                            filterVM.options.selectedCountries.removeAll()
                        } else {
                            if filterVM.options.selectedCountries.contains(country) {
                                filterVM.options.selectedCountries.remove(country)
                            } else {
                                filterVM.options.selectedCountries.insert(country)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
} 