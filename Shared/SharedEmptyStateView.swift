import SwiftUI

struct SharedEmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(AppColors.primary)
                .padding(.bottom, 8)
            
            Text(message)
                .font(AppFonts.primaryFont(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Vista previa
struct SharedEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        SharedEmptyStateView(message: "No hay elementos para mostrar.")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
