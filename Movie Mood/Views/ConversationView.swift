import SwiftUI

struct ConversationView: View {
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var movieListVM: MovieListViewModel
    var onFinish: () -> Void

    var isDataLoaded: Bool {
        // Check if all parameters are loaded (if any is empty, returns false)
        !movieListVM.availableGenres.isEmpty &&
        !movieListVM.availableCountries.isEmpty &&
        !movieListVM.availableLanguages.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                ProgressView(value: Double(filterVM.currentStep + 1), total: Double(filterVM.totalSteps))
                    .accentColor(.blue)
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)
                    .padding(.top, 16)
                Text("Step \(filterVM.currentStep + 1) of \(filterVM.totalSteps)")
                    .font(.headline.bold())
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<filterVM.currentStep, id: \.self) { step in
                        Button(action: { withAnimation { filterVM.currentStep = step } }) {
                            previousAnswerView(for: step)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 120)
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.12), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom))
                    .shadow(color: .blue.opacity(0.15), radius: 12, x: 0, y: 8)
                VStack(spacing: 20) {
                    questionView(for: filterVM.currentStep)
                        .environmentObject(movieListVM)
                }
                .padding(24)
            }
            .padding(.horizontal)
            .frame(maxWidth: 500)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            Spacer(minLength: 0)
            Button(filterVM.currentStep == filterVM.totalSteps - 1 ? "Finish and Show Movies" : "Next") {
                if filterVM.currentStep == filterVM.totalSteps - 1 {
                    onFinish()
                } else {
                    filterVM.nextStep()
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.title2.bold())
            .padding(.top, 12)
            .disabled(!isDataLoaded)
        }
        .padding(.bottom, 16)
        .animation(.spring(), value: filterVM.currentStep)
    }

    @ViewBuilder
    func questionView(for step: Int) -> some View {
        switch step {
        case 0: GenreQuestionView(filterVM: filterVM)
        case 1: YearQuestionView(filterVM: filterVM)
        case 2: RatingQuestionView(filterVM: filterVM)
        case 3: RuntimeQuestionView(filterVM: filterVM)
        case 4: CountryQuestionView(filterVM: filterVM)
        case 5: LanguageQuestionView(filterVM: filterVM)
        default: EmptyView()
        }
    }

    @ViewBuilder
    func previousAnswerView(for step: Int) -> some View {
        HStack(alignment: .top) {
            Circle().fill(Color.blue).frame(width: 10, height: 10)
            Text(answerText(for: step))
                .font(.callout)
                .foregroundColor(.primary)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.leading, 8)
    }

    func answerText(for step: Int) -> String {
        switch step {
        case 0:
            let genres = filterVM.options.selectedGenres
            return genres.isEmpty ? "Genres: Any" : "Genres: " + genres.joined(separator: ", ")
        case 1:
            let year = filterVM.options.releaseAfter.prefix(4)
            return year.isEmpty ? "Year: Any" : "Year: after \(year)"
        case 2:
            return "IMDB: \(String(format: "%.1f", filterVM.options.minRating)) and above"
        case 3:
            return "Runtime: up to \(filterVM.options.maxRuntime) min"
        case 4:
            let countries = filterVM.options.selectedCountries
            return countries.isEmpty ? "Countries: Any" : "Countries: " + countries.joined(separator: ", ")
        case 5:
            return filterVM.options.selectedLanguage.isEmpty ? "Language: Any" : "Language: \(filterVM.options.selectedLanguage.uppercased())"
        default:
            return ""
        }
    }
} 
