import SwiftUI

struct RuntimeQuestionView: View {
    @ObservedObject var filterVM: FilterViewModel
    @State private var runtime: Double
    @State private var anyRuntime: Bool

    init(filterVM: FilterViewModel) {
        self.filterVM = filterVM
        let isAny = filterVM.options.maxRuntime == 0
        _anyRuntime = State(initialValue: isAny)
        _runtime = State(initialValue: isAny ? 120 : Double(filterVM.options.maxRuntime))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Maximum runtime (min)?")
                .font(.title2.bold())
            Slider(value: $runtime, in: 60...240, step: 1)
                .disabled(anyRuntime)
            HStack {
                Text("\(Int(runtime)) min")
                    .font(.title2.bold())
                    .foregroundColor(.accentColor)
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    anyRuntime.toggle()
                    if anyRuntime {
                        filterVM.options.maxRuntime = 0
                    } else {
                        filterVM.options.maxRuntime = Int(runtime)
                    }
                }) {
                    Text("Any")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(anyRuntime ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                        .foregroundColor(anyRuntime ? .blue : .primary)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(anyRuntime ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                Spacer()
            }
            if anyRuntime {
                Text("No runtime limit")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onChange(of: runtime) { newValue in
            if !anyRuntime {
                filterVM.options.maxRuntime = Int(newValue)
            }
        }
    }
} 
