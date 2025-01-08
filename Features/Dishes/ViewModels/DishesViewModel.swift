import Foundation

class DishesViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    
    init() {
        loadDishes()
    }
    
    func loadDishes() {
        if let savedDishes = PersistenceHelper.load([Dish].self, from: "dishes.json") {
            dishes = savedDishes
        } else {
            dishes = []
        }
    }
    
    func saveDishes() {
        PersistenceHelper.save(dishes, to: "dishes.json")
    }
    
    func addDish(_ dish: Dish) {
        dishes.append(dish)
        saveDishes()
    }
    
    func deleteDish(_ dish: Dish) {
        dishes.removeAll { $0.id == dish.id }
        saveDishes()
    }
    
    func updateDish(_ updatedDish: Dish) {
        if let index = dishes.firstIndex(where: { $0.id == updatedDish.id }) {
            dishes[index] = updatedDish
            saveDishes()
        }
    }
}
