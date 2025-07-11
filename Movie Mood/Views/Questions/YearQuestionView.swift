import SwiftUI

struct YearQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    let minYear = 1980
    let maxYear = 2023

    @State private var selectedYear: Int

    init(filterVM: FilterViewModel) {
        self.filterVM = filterVM
        // If releaseAfter is empty, default to year 2000
        if filterVM.options.releaseAfter.isEmpty {
            _selectedYear = State(initialValue: 2000)
        } else {
            let yearString = String(filterVM.options.releaseAfter.prefix(4))
            _selectedYear = State(initialValue: Int(yearString) ?? 2000)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Release after which year?")
                .font(.title2.bold())
            
            VStack(spacing: 12) {
                Text("\(selectedYear)")
                    .font(.title.bold())
                    .foregroundColor(.blue)
                
                Slider(value: Binding(
                    get: { Double(selectedYear) },
                    set: { 
                        selectedYear = Int($0)
                        filterVM.setReleaseAfter(year: selectedYear)
                    }
                ), in: Double(minYear)...Double(maxYear), step: 1)
                
                HStack {
                    Text("\(minYear)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(maxYear)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            // Save selected year to FilterOptions when view appears
            filterVM.setReleaseAfter(year: selectedYear)
        }
    }
} 
