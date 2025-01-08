import SwiftUI

struct AppFonts {
    static func primaryFont(size: CGFloat) -> Font {
        return Font.custom("HelveticaNeue", size: size) // Cambia "HelveticaNeue" por el nombre de tu fuente
    }
    
    static func secondaryFont(size: CGFloat) -> Font {
        return Font.custom("ArialRoundedMTBold", size: size) // Cambia según tu configuración
    }
}
