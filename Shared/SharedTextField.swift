import SwiftUI

struct SharedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .font(AppFonts.primaryFont(size: 14))
    }
}

// Vista previa
struct SharedTextField_Previews: PreviewProvider {
    static var previews: some View {
        SharedTextField(
            placeholder: "Introduce tu texto aquí",
            text: .constant("")
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
