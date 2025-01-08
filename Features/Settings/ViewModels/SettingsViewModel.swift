import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settings: RestaurantSettings
    
    init() {
        if let savedSettings = PersistenceHelper.load(RestaurantSettings.self, from: "settings.json") {
            settings = savedSettings
        } else {
            settings = RestaurantSettings(
                restaurantName: "",
                restaurantSlogan: "",
                email: "",
                phone: "",
                website: "",
                addressStreet: "",
                addressCity: "",
                addressPostalCode: "",
                addressCountry: "",
                logoData: nil,
                costIncludedDrink: 0.0,
                costIncludedWater: 0.0,
                costIncludedBread: 0.0,
                costIncludedCoffee: 0.0,
                costIncludedWinePairing: 0.0
            )
        }
    }
    
    func saveSettings() {
        PersistenceHelper.save(settings, to: "settings.json")
    }
}
