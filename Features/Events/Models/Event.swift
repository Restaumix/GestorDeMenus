import Foundation

struct Event: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    var date: Date
    var serviceType: String
    var numberOfGuests: Int
    var estimatedDuration: String
    var minPrice: Double = 0.0
    var maxPrice: Double = 0.0
    var additionalNotes: String
    var status: String = "Por enviar"
}
