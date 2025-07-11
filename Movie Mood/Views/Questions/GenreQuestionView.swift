import SwiftUI

struct GenreQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var movieListVM: MovieListViewModel

    var body: some View {
        let allGenres = filterVM.allGenres(from: movieListVM)
        let isAnySelected = !filterVM.options.selectedGenres.isEmpty
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Which genres do you prefer?")
                .font(.title2.bold())
            
            if allGenres.isEmpty {
                ProgressView("Loading genres...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                WrapHStack(["Any"] + allGenres, id: \.self) { genre in
                    ChipView(
                        text: genre,
                        isSelected: genre == "Any" ? !isAnySelected : filterVM.options.selectedGenres.contains(genre)
                    ) {
                        if genre == "Any" {
                            filterVM.options.selectedGenres.removeAll()
                        } else {
                            if filterVM.options.selectedGenres.contains(genre) {
                                filterVM.options.selectedGenres.remove(genre)
                            } else {
                                filterVM.options.selectedGenres.insert(genre)
                            }
                        }
                    }
                }
            }
        }
    }
} 