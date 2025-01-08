import SwiftUI

struct SharedLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Text("Cargando...")
                .font(AppFonts.primaryFont(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding()
    }
}

// Vista previa
struct SharedLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        SharedLoadingView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
