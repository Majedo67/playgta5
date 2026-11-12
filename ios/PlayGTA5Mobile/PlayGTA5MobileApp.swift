import SwiftUI

@main
struct PlayGTA5MobileApp: App {
    var body: some Scene {
        WindowGroup { GameView() }
    }
}

struct GameView: View {
    @State private var address = "http://192.168.1.100:8000"
    @State private var showAddress = true
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GameWebView(address: address, showAddress: $showAddress).ignoresSafeArea()
            if showAddress {
                VStack(spacing: 14) {
                    Text("PlayGTA5 Mobile").font(.title.bold()).foregroundStyle(.white)
                    Text("Enter the game host address on the same Wi-Fi network.")
                        .font(.footnote).foregroundStyle(.white.opacity(0.8)).multilineTextAlignment(.center)
                    TextField("http://192.168.1.20:8000", text: $address)
                        .textInputAutocapitalization(.never).keyboardType(.URL).autocorrectionDisabled()
                        .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                    Button("Open Game") { showAddress = false }
                        .font(.headline).foregroundStyle(.black).padding(.horizontal, 28).padding(.vertical, 12)
                        .background(Color.green).clipShape(Capsule())
                }.padding(22).background(Color.black.opacity(0.9)).clipShape(RoundedRectangle(cornerRadius: 18)).padding(24)
            }
        }.statusBarHidden()
    }
}
