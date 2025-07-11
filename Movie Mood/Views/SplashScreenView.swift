import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var isActive = false
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                LottieView(name: "movie", loopMode: .loop)
                    .frame(width: 180, height: 180)
                Text("Movie Mood")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.purple, Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                    .kerning(2)
                Text("Your Movie Assistant")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.top, -12)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { isActive = true }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}

// LottieView SwiftUI Wrapper
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
} 
