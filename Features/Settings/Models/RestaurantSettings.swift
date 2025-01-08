import Foundation
import UIKit

struct RestaurantSettings: Codable, Equatable {
    var restaurantName: String
    var restaurantSlogan: String
    var email: String
    var phone: String
    var website: String
    var addressStreet: String
    var addressCity: String
    var addressPostalCode: String
    var addressCountry: String
    var logoData: Data?
    
    var logoImage: UIImage? {
        get {
            if let data = logoData {
                return UIImage(data: data)
            }
            return nil
        }
        set {
            logoData = newValue?.pngData()
        }
    }
    
    var costIncludedDrink: Double
    var costIncludedWater: Double
    var costIncludedBread: Double
    var costIncludedCoffee: Double
    var costIncludedWinePairing: Double
}
