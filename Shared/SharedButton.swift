import SwiftUI

struct SharedButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.primaryFont(size: 16))
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

// Vista previa
struct SharedButton_Previews: PreviewProvider {
    static var previews: some View {
        SharedButton(
            title: "Aceptar",
            action: { print("Button tapped") },
            backgroundColor: AppColors.primary,
            textColor: .white
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
