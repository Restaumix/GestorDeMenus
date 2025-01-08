import SwiftUI

struct SharedErrorView: View {
    let errorMessage: String
    let onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(errorMessage)
                .font(AppFonts.primaryFont(size: 16))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Reintentar")
                        .font(AppFonts.primaryFont(size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// Vista previa
struct SharedErrorView_Previews: PreviewProvider {
    static var previews: some View {
        SharedErrorView(
            errorMessage: "Ha ocurrido un error desconocido.",
            onRetry: { print("Retry tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
