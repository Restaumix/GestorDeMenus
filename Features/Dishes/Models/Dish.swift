import Foundation

struct Dish: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var foodCost: Double?
    var allergens: [String]
    var types: [String]
    var category: String
}
