import SwiftUI

struct RatingQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    @State private var rating: Double

    init(filterVM: FilterViewModel) {
        self.filterVM = filterVM
        _rating = State(initialValue: filterVM.options.minRating)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Minimum IMDB rating?")
                .font(.title2.bold())
            HStack {
                Slider(value: $rating, in: 0...10, step: 0.1)
                Text(String(format: "%.1f", rating))
                    .font(.title2.bold())
                    .foregroundColor(.accentColor)
            }
        }
        .onChange(of: rating) { newValue in
            filterVM.options.minRating = newValue
        }
    }
} 
