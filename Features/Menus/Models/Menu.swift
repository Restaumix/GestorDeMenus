import Foundation

struct Menu: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    var price: Double
    var isDrinkIncluded: Bool
    var drinkDescription: String
    var isWaterIncluded: Bool
    var waterDescription: String
    var isBreadIncluded: Bool
    var breadDescription: String
    var isCoffeeIncluded: Bool
    var coffeeDescription: String
    var isWinePairingIncluded: Bool
    var winePairingDescription: String
    var mealType: String
    var associatedDishes: [Dish] = []
}
