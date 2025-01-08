import Foundation

class MenusViewModel: ObservableObject {
    @Published var menus: [Menu] = []
    
    init() {
        loadMenus()
    }
    
    func loadMenus() {
        if let savedMenus = PersistenceHelper.load([Menu].self, from: "menus.json") {
            menus = savedMenus
        } else {
            menus = []
        }
    }
    
    func saveMenus() {
        PersistenceHelper.save(menus, to: "menus.json")
    }
    
    func addMenu(_ menu: Menu) {
        menus.append(menu)
        saveMenus()
    }
    
    func deleteMenu(_ menu: Menu) {
        menus.removeAll { $0.id == menu.id }
        saveMenus()
    }
    
    func updateMenu(_ updatedMenu: Menu) {
        if let index = menus.firstIndex(where: { $0.id == updatedMenu.id }) {
            menus[index] = updatedMenu
            saveMenus()
        }
    }
}
