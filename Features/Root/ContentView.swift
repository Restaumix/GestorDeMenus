//
//  ContentView.swift
//  MenuEvents
//
//  Created by Ejemplo on 24/12/2024.
//

import SwiftUI

// MARK: - Extension para ocultar el teclado
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

// MARK: - Modelos

struct Dish: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var foodCost: Double?
    var allergens: [String]
    var types: [String]
    var category: String
}

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

struct RestaurantSettings: Codable, Equatable {
    // Datos básicos
    var restaurantName: String
    var restaurantSlogan: String
    var email: String
    var phone: String
    var website: String
    
    // Dirección
    var addressStreet: String
    var addressCity: String
    var addressPostalCode: String
    var addressCountry: String
    
    // Logo
    var logoData: Data?
        
        // Computed property para transformar Data <-> UIImage
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
        
        // Precios de coste ...
        var costIncludedDrink: Double
        var costIncludedWater: Double
        var costIncludedBread: Double
        var costIncludedCoffee: Double
        var costIncludedWinePairing: Double
    }

struct ColorSegmentedPicker: View {
    @Binding var selection: String
    let items: [(String, Color)]  // Par de (texto, color)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { i in
                let (title, color) = items[i]
                
                Button(action: {
                    // Actualizamos la selección al pulsar
                    selection = title
                }) {
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(selection == title ? .white : .primary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        // Si está seleccionado, fondo de su color
                        // si no, un gris claro
                        .background(selection == title ? color : Color(UIColor.systemGray5))
                }
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

// MARK: - Helpers

/// Formatea la moneda para el campo “Coste de ingredientes”.
func currencyFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter
}

/// Formatea el coste de un plato como "(3.50 €)" o "(0.00 €)" si es nil.
func formattedCost(_ cost: Double?) -> String {
    guard let cost = cost else {
        return "(0.00 €)"
    }
    return String(format: "(%.2f €)", cost)
}

/// Calcula la **media** del `foodCost` en cada categoría, luego **suma** esas medias.
/// Representa el coste promedio total (un plato por categoría).
func averageCostOfMenu(dishes: [Dish]) -> Double {
    // Agrupamos platos por categoría
    let grouped = Dictionary(grouping: dishes, by: { $0.category })
    
    var total: Double = 0
    // Para cada categoría principal, si hay platos en ella, calculamos la media
    for category in ["Aperitivo", "Entrantes", "Segundos", "Postres"] {
        if let group = grouped[category], !group.isEmpty {
            let sumCat = group.compactMap({ $0.foodCost }).reduce(0, +)
            let avgCat = sumCat / Double(group.count)
            total += avgCat
        }
    }
    return total
}

/// Según el coste promedio total vs. PVP, devolvemos un mensaje y color de rentabilidad
/// - <= 25%  → Verde + “Rentabilidad alta”
/// - <= 30%  → Naranja + “Atención”
/// -  > 30%  → Rojo + “Alerta”
func rentabilityInfo(for menu: Menu) -> (String, Color) {
    let costAvg = averageCostOfMenu(dishes: menu.associatedDishes)
    
    // Sin datos si coste = 0 o PVP = 0
    guard menu.price > 0, costAvg > 0 else {
        return ("Selecciona platos para información de rentabilidad", .black)
    }
    
    let ratio = costAvg / menu.price
    if ratio <= 0.25 {
        return ("Felicidades por buena rentabilidad: El coste de ingredientes está por debajo del 25% del PVP.", .green)
    } else if ratio <= 0.30 {
        return ("Atención por baja rentabilidad: El coste de ingredientes está cerca del 30% del PVP.", .orange)
    } else {
        return ("Alerta por nula rentabilidad: El coste de ingredientes es superior al 30% del PVP.", .red)
    }
}
/// Función auxiliar para crear fechas
func createDate(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
    var components = DateComponents()
    components.day = day
    components.month = month
    components.year = year
    components.hour = hour
    components.minute = minute
    let calendar = Calendar.current
    return calendar.date(from: components) ?? Date()
}

// MARK: - ContentView (TabView Principal)

struct ContentView: View {
    @State private var dishes: [Dish] = []
    @State private var menus: [Menu] = []
    @State private var events: [Event] = []
    
    // Ajustes del restaurante
    @State private var restaurantSettings = RestaurantSettings(
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
    
    var body: some View {
        TabView {
            DishesView(dishes: $dishes)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Platos")
                }
            
            MenusView(menus: $menus, dishes: $dishes)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Menús")
                }
            
            EventsView(events: $events)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Eventos")
                }
            
            SettingsView(settings: $restaurantSettings)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Ajustes")
                }
        }
        .hideKeyboardOnTap() // Aquí aplicamos el modificador global
 
        .onAppear {
            // 1) Cargar o crear datos de platos
            if let savedDishes = PersistenceHelper.load([Dish].self, from: "dishes.json") {
                dishes = savedDishes
            } else {
                // No existía dishes.json. Creamos datos por defecto:
                dishes = [
                    // -- APERITIVOS
                    Dish(
                        title: "Bruschetta Caprese",
                        description: "Rebanadas de pan crujiente con tomate fresco, albahaca y queso mozzarella.",
                        foodCost: 0.85,
                        allergens: ["Gluten", "Lácteos"],
                        types: ["Vegetariano"],
                        category: "Aperitivo"
                    ),
                    Dish(
                        title: "Croquetas de jamón ibérico",
                        description: "Croquetas cremosas con bechamel y trocitos de jamón ibérico.",
                        foodCost: 1.30,
                        allergens: ["Gluten", "Lácteos"],
                        types: [],
                        category: "Aperitivo"
                    ),
                    Dish(
                        title: "Rollitos de pepino con hummus",
                        description: "Pepino relleno de hummus clásico, aromatizado con especias.",
                        foodCost: 0.95,
                        allergens: ["Sésamo"],
                        types: ["Vegano", "Sin Gluten"],
                        category: "Aperitivo"
                    ),
                    
                    // -- ENTRANTES
                    Dish(
                        title: "Ensalada griega",
                        description: "Lechuga, tomate, pepino, cebolla roja, aceitunas y queso feta.",
                        foodCost: 1.55,
                        allergens: ["Lácteos"],
                        types: ["Vegetariano"],
                        category: "Entrantes"
                    ),
                    Dish(
                        title: "Crema de calabaza",
                        description: "Puré de calabaza, cebolla y caldo de verduras, con un chorrito de aceite.",
                        foodCost: 0.85,
                        allergens: ["Apio", "Sulfitos"],
                        types: ["Vegano", "Sin Gluten"],
                        category: "Entrantes"
                    ),
                    Dish(
                        title: "Gazpacho andaluz",
                        description: "Tomate, pepino, pimiento, ajo, aceite de oliva y vinagre.",
                        foodCost: 0.80,
                        allergens: [],
                        types: ["Vegano", "Sin Gluten"],
                        category: "Entrantes"
                    ),
                    
                    // -- SEGUNDOS
                    Dish(
                        title: "Pollo al curry con arroz",
                        description: "Pollo en leche de coco al curry, acompañado de arroz basmati.",
                        foodCost: 1.50,
                        allergens: ["Sulfitos", "Lácteos"],
                        types: ["Sin Gluten"],
                        category: "Segundos"
                    ),
                    Dish(
                        title: "Lasaña de vegetales",
                        description: "Capas de pasta, calabacín, berenjena, salsa de tomate y queso.",
                        foodCost: 1.50,
                        allergens: ["Gluten", "Lácteos"],
                        types: ["Vegetariano"],
                        category: "Segundos"
                    ),
                    Dish(
                        title: "Salmón con limón y eneldo",
                        description: "Lomos de salmón horneados con una salsa ligera de limón y mantequilla.",
                        foodCost: 2.75,
                        allergens: ["Pescado", "Lácteos"],
                        types: ["Sin Gluten"],
                        category: "Segundos"
                    ),
                    
                    // -- POSTRES
                    Dish(
                        title: "Tarta de queso",
                        description: "Base de galletas y mezcla horneada de queso crema, huevos y azúcar.",
                        foodCost: 0.58,
                        allergens: ["Gluten", "Lácteos", "Huevos"],
                        types: [],
                        category: "Postres"
                    ),
                    Dish(
                        title: "Mousse de chocolate",
                        description: "Crema suave a base de chocolate fundido, huevos y nata.",
                        foodCost: 0.62,
                        allergens: ["Lácteos", "Huevos"],
                        types: ["Sin Gluten"],
                        category: "Postres"
                    ),
                    Dish(
                        title: "Macedonia de frutas frescas",
                        description: "Frutas de temporada con zumo de naranja natural.",
                        foodCost: 0.80,
                        allergens: [],
                        types: ["Vegano", "Vegetariano", "Sin Gluten"],
                        category: "Postres"
                    )
                ]
                // Guardamos para crear el archivo dishes.json
                PersistenceHelper.save(dishes, to: "dishes.json")
            }
            
            // 2) Cargar o crear menús
            if let savedMenus = PersistenceHelper.load([Menu].self, from: "menus.json") {
                menus = savedMenus
            } else {
                // No existía menus.json. Creamos datos por defecto:
                menus = [
                    Menu(
                        name: "Menú del día",
                        description: "Almuerzo diario con platos fijos a precio cerrado.",
                        price: 12.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Almuerzo"
                    ),
                    Menu(
                        name: "Menú desayuno fin de semana",
                        description: "Propuestas especiales para sábados, domingos y festivos.",
                        price: 12.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Desayuno"
                    ),
                    Menu(
                        name: "Menú fin de semana",
                        description: "Propuestas especiales para sábados, domingos y festivos.",
                        price: 25.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Almuerzo"
                    ),
                    Menu(
                        name: "Menú degustación",
                        description: "Recorrido de pequeños platos con opción de maridaje.",
                        price: 24.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Cena"
                    ),
                    Menu(
                        name: "Menú de temporada",
                        description: "Platos basados en ingredientes frescos de estación.",
                        price: 22.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Almuerzo"
                    ),
                    Menu(
                        name: "Menú para grupos",
                        description: "Opciones personalizadas para celebraciones con precio por persona.",
                        price: 0.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Almuerzo"
                    ),
                    Menu(
                        name: "Menú para empresas",
                        description: "Opciones personalizadas para celebraciones con precio por persona.",
                        price: 0.00,
                        isDrinkIncluded: false,
                        drinkDescription: "Este menú incluye una bebida por persona (vino, cerveza, agua o refresco).",
                        isWaterIncluded: false,
                        waterDescription: "Agua embotellada/filtrada incluida en el menú sin coste adicional.",
                        isBreadIncluded: false,
                        breadDescription: "Servicio de pan incluido en el menú.",
                        isCoffeeIncluded: false,
                        coffeeDescription: "Este menú incluye un café por persona al finalizar la comida.",
                        isWinePairingIncluded: false,
                        winePairingDescription: "Ofrecemos un maridaje de vinos recomendado para cada plato.",
                        mealType: "Cena"
                    )
                ]
                PersistenceHelper.save(menus, to: "menus.json")
            }
            
            // 3) Cargar o crear eventos
            if let savedEvents = PersistenceHelper.load([Event].self, from: "events.json") {
                events = savedEvents
            } else {
                // No existía events.json. Creamos datos por defecto:
                events = [
                    Event(
                        name: "Cena de empresa Tech Solutions",
                        description: "Encuentro anual de los empleados de Tech Solutions, con un menú especial...",
                        date: createDate(day: 20, month: 1, year: 2025, hour: 20, minute: 30),
                        serviceType: "Cena",
                        numberOfGuests: 50,
                        estimatedDuration: "3 horas",
                        minPrice: 45.0,
                        maxPrice: 65.0,
                        additionalNotes: "Habrá opciones veganas y sin gluten. Se habilitará un espacio para proyecciones y discursos."
                    ),
                    Event(
                        name: "50º Cumpleaños de Marta Gómez",
                        description: "Celebración íntima del 50º cumpleaños de Marta Gómez, con un menú especial...",
                        date: createDate(day: 15, month: 3, year: 2025, hour: 14, minute: 0),
                        serviceType: "Almuerzo",
                        numberOfGuests: 20,
                        estimatedDuration: "4 horas",
                        minPrice: 45.0,
                        maxPrice: 65.0,
                        additionalNotes: "Decoración personalizada incluida. Se ofrecerá cava para el brindis."
                    ),
                    Event(
                        name: "Aniversario de Laura y Javier",
                        description: "Celebración de las bodas de plata de Laura y Javier, con un menú degustación...",
                        date: createDate(day: 10, month: 6, year: 2025, hour: 19, minute: 0),
                        serviceType: "Cena",
                        numberOfGuests: 40,
                        estimatedDuration: "3 horas",
                        minPrice: 45.0,
                        maxPrice: 65.0,
                        additionalNotes: "Incluye tarta conmemorativa y un brindis especial con cava del Penedès."
                    ),
                    Event(
                        name: "Cena fin de curso de Bachillerato",
                        description: "Despedida del curso con los estudiantes de último año de bachillerato...",
                        date: createDate(day: 27, month: 6, year: 2025, hour: 20, minute: 0),
                        serviceType: "Cena",
                        numberOfGuests: 70,
                        estimatedDuration: "4 horas",
                        minPrice: 45.0,
                        maxPrice: 65.0,
                        additionalNotes: "Incluye DJ en vivo y opciones vegetarianas."
                    ),
                    Event(
                        name: "80º Cumpleaños de Josep Costa",
                        description: "Celebración del 80º cumpleaños de Josep con su familia y amigos más cercanos...",
                        date: createDate(day: 5, month: 9, year: 2025, hour: 13, minute: 30),
                        serviceType: "Almuerzo",
                        numberOfGuests: 30,
                        estimatedDuration: "3 horas",
                        minPrice: 45.0,
                        maxPrice: 65.0,
                        additionalNotes: "Se habilitará un proyector para videos familiares. Habrá un menú especial para niños."
                    )
                ]
                PersistenceHelper.save(events, to: "events.json")
            }
            
            // 4) Cargar o crear ajustes
            if let savedSettings = PersistenceHelper.load(RestaurantSettings.self, from: "settings.json") {
                restaurantSettings = savedSettings
            } else {
                // No existía settings.json. Creamos por defecto
                restaurantSettings = RestaurantSettings(
                    restaurantName: "Mi Restaurante",
                    restaurantSlogan: "Tu eslogan aquí",
                    email: "info@restaurante.com",
                    phone: "555-1234",
                    website: "www.restaurante.com",
                    addressStreet: "Calle Principal 123",
                    addressCity: "Barcelona",
                    addressPostalCode: "08000",
                    addressCountry: "España",
                    logoData: nil,
                    
                    costIncludedDrink: 0.75,
                    costIncludedWater: 0.25,
                    costIncludedBread: 0.15,
                    costIncludedCoffee: 0.30,
                    costIncludedWinePairing: 4.00
                )
                PersistenceHelper.save(restaurantSettings, to: "settings.json")
            }
        }
        // Además, con .onChange(...) guardas cuando cambien
        .onChange(of: dishes) {
            PersistenceHelper.save(dishes, to: "dishes.json")
        }
        .onChange(of: menus) {
            PersistenceHelper.save(menus, to: "menus.json")
        }
        .onChange(of: events) {
            PersistenceHelper.save(events, to: "events.json")
        }
        .onChange(of: restaurantSettings) {
            PersistenceHelper.save(restaurantSettings, to: "settings.json")
        }
    }
}


// MARK: - Vista de platos

struct DishesView: View {
    @Binding var dishes: [Dish]
    @State private var isPresentingAddDishView = false
    
    let categoryOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
    
    var groupedDishes: [String: [Dish]] {
        Dictionary(grouping: dishes, by: { $0.category })
    }
    
    var sortedCategories: [String] {
        categoryOrder.filter { groupedDishes.keys.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Cabecera
                HStack {
                    Text("Platos")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        isPresentingAddDishView = true
                    } label: {
                        Text("Añadir Plato")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding([.leading, .trailing, .top])
                
                if dishes.isEmpty {
                    Text("No hay platos aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(sortedCategories, id: \.self) { category in
                            Section(header: Text(category)) {
                                ForEach(groupedDishes[category] ?? []) { dish in
                                    NavigationLink {
                                        EditDishView(dish: binding(for: dish), dishes: $dishes)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(dish.title).font(.headline)
                                            Text(dish.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isPresentingAddDishView) {
                AddDishView(dishes: $dishes)
            }
        }
    }
    
    private func binding(for dish: Dish) -> Binding<Dish> {
        guard let index = dishes.firstIndex(where: { $0.id == dish.id }) else {
            fatalError("Plato no encontrado")
        }
        return $dishes[index]
    }
}

// MARK: - Añadir platos

struct AddDishView: View {
    @Binding var dishes: [Dish]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var foodCost: String = ""
    @State private var selectedCategory: String = "Aperitivo"
    
    @State private var allergens: Set<String> = []
    @State private var types: Set<String> = []
    
    let allergenOptions = ["Gluten", "Lácteos", "Frutos Secos", "Huevo", "Marisco", "Mostaza", "Sésamo", "Soja", "Apio", "Pescado"]
    let typeOptions = ["Sin Gluten", "Vegano", "Vegetariano"]
    let categoryOptions = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Section(header: Text("Información del plato:").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            TextField("Título", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            TextField("Descripción", text: $description)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categoría")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Picker("Categoría", selection: $selectedCategory) {
                                ForEach(categoryOptions, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coste de ingredientes (€)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            HStack {
                                TextField("Coste de ingredientes", text: $foodCost)
                                    .textFieldStyleWithBackground()      // <- Aplica tu propio estilo
                                    .multilineTextAlignment(.leading)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                    }

                    
                    Section(header: Text("Alérgenos:").font(.headline)) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(allergenOptions, id: \.self) { allergen in
                                Button {
                                    toggleSelection(for: allergen, in: &allergens)
                                } label: {
                                    Text(allergen)
                                        .padding(5)
                                        .frame(maxWidth: .infinity)
                                        .background(allergens.contains(allergen)
                                                    ? Color.red.opacity(0.2)
                                                    : Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Tipo de plato:").font(.headline)) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(typeOptions, id: \.self) { type in
                                Button {
                                    toggleSelection(for: type, in: &types)
                                } label: {
                                    Text(type)
                                        .padding(5)
                                        .frame(maxWidth: .infinity)
                                        .background(types.contains(type)
                                                    ? Color.green.opacity(0.2)
                                                    : Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                    
                    Button {
                        let newDish = Dish(
                            title: title,
                            description: description,
                            foodCost: Double(foodCost),
                            allergens: Array(allergens),
                            types: Array(types),
                            category: selectedCategory
                        )
                        dishes.append(newDish)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Guardar plato")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    
                }
                .padding()
                        // AÑADE ESTAS DOS LÍNEAS:
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    .navigationTitle("Añadir plato")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
    }
    
    private func toggleSelection(for item: String, in set: inout Set<String>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

// MARK: - Editar platos

struct EditDishView: View {
    @Binding var dish: Dish
    @Binding var dishes: [Dish]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sección: Información del Plato
                Section(header: Text("Información del plato:").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Introduce el título", text: $dish.title)
                            .textFieldStyleWithBackground()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Introduce la descripción", text: $dish.description)
                            .textFieldStyleWithBackground()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categoría")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Selecciona la categoría", selection: $dish.category) {
                            ForEach(["Aperitivo", "Entrantes", "Segundos", "Postres"], id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coste de ingredientes (€)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Introduce el coste", value: $dish.foodCost, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyleWithBackground()
                            .multilineTextAlignment(.leading)
                    }
                }
                
                .onTapGesture {
                    UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                }

                
                // Sección: Alérgenos
                Section(header: Text("Alérgenos:").font(.headline)) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(["Gluten", "Lácteos", "Frutos Secos", "Huevo", "Marisco", "Mostaza", "Sésamo", "Soja", "Apio", "Pescado"], id: \.self) { allergen in
                            Button {
                                if let index = dish.allergens.firstIndex(of: allergen) {
                                    dish.allergens.remove(at: index)
                                } else {
                                    dish.allergens.append(allergen)
                                }
                            } label: {
                                Text(allergen)
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                                    .background(dish.allergens.contains(allergen) ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .font(.footnote)
                            }
                        }
                    }
                }

                // Sección: Tipo de Plato
                Section(header: Text("Tipo de plato:").font(.headline)) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(["Sin Gluten", "Vegano", "Vegetariano"], id: \.self) { type in
                            Button {
                                if let index = dish.types.firstIndex(of: type) {
                                    dish.types.remove(at: index)
                                } else {
                                    dish.types.append(type)
                                }
                            } label: {
                                Text(type)
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                                    .background(dish.types.contains(type) ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .font(.footnote)
                            }
                        }
                    }
                }

                // Botón: Guardar Cambios
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Guardar cambios")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

                // Botón: Eliminar Plato
                Button {
                    if let index = dishes.firstIndex(where: { $0.id == dish.id }) {
                        dishes.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Eliminar plato")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)

                // Botón: Duplicar Plato
                Button {
                    let duplicated = Dish(
                        title: dish.title + " (Copia)",
                        description: dish.description,
                        foodCost: dish.foodCost,
                        allergens: dish.allergens,
                        types: dish.types,
                        category: dish.category
                    )
                    dishes.append(duplicated)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Duplicar plato")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(UIColor.systemGray6)) // Fondo gris claro
        }
        .navigationTitle("Editar plato")
    }
}

// MARK: - Modificador personalizado para TextField
extension View {
    func textFieldStyleWithBackground() -> some View {
        self.modifier(TextFieldBackgroundStyle())
    }
}

struct TextFieldBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color.white) // Fondo blanco
            .cornerRadius(8)
            .shadow(color: Color.gray.opacity(0.3), radius: 1, x: 0, y: 1) // Pequeña sombra
    }
}


// MARK: - MenusView (contiene la presentación de AddMenuView y la navegación a EditMenuView)

struct MenusView: View {
    @Binding var menus: [Menu]
    @Binding var dishes: [Dish]
    
    @State private var isPresentingAddMenuView = false
    
    let mealTypeOrder = ["", "Desayuno", "Almuerzo", "Cena"] // "" representa los menús sin tipo definido
    
    // Agrupamos y ordenamos los menús
    var groupedAndSortedMenus: [String: [Menu]] {
        // Primero, ordenamos los menús:
        let sortedMenus = menus.sorted { menu1, menu2 in
            let index1 = mealTypeOrder.firstIndex(of: menu1.mealType) ?? mealTypeOrder.count
            let index2 = mealTypeOrder.firstIndex(of: menu2.mealType) ?? mealTypeOrder.count
            return index1 < index2
        }
        
        // Luego, agrupamos por tipo de comida:
        return Dictionary(grouping: sortedMenus, by: { $0.mealType })
    }
    
    // Ordenamos las categorías visibles (incluyendo menús sin tipo informado)
    var sortedCategories: [String] {
        mealTypeOrder.filter { groupedAndSortedMenus.keys.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Menús")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    // Botón para añadir un menú
                    Button {
                        isPresentingAddMenuView = true
                    } label: {
                        Text("Añadir menú")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding([.leading, .trailing, .top])
                
                if menus.isEmpty {
                    Text("No hay menús aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(sortedCategories, id: \.self) { category in
                            Section(header: Text(category.isEmpty ? "Sin tipo de servicio:" : category)) {
                                ForEach(groupedAndSortedMenus[category] ?? []) { menu in
                                    NavigationLink {
                                        EditMenuView(menu: binding(for: menu),
                                                     menus: $menus,
                                                     dishes: $dishes)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                // Nombre del menú
                                                Text(menu.name)
                                                    .font(.headline)
                                                Spacer()
                                                // PVP con color basado en rentabilidad
                                                let rentability = rentabilityInfo(for: menu)
                                                Text(String(format: "%.2f €", menu.price))
                                                    .font(.subheadline)
                                                    .foregroundColor(rentability.1) // Cambiar color
                                            }
                                            Text(menu.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            // Presentamos la AddMenuView con la lógica de crear un nuevo Menú
            .sheet(isPresented: $isPresentingAddMenuView) {
                AddMenuView(menus: $menus, dishes: $dishes)
            }
        }
    }
    
    private func binding(for menu: Menu) -> Binding<Menu> {
        guard let index = menus.firstIndex(where: { $0.id == menu.id }) else {
            fatalError("Menú no encontrado")
        }
        return $menus[index]
    }
}



// MARK: - NUEVA: AddMenuView para crear un nuevo Menú

struct AddMenuView: View {
    @Binding var menus: [Menu]
    @Binding var dishes: [Dish]
    
    @Environment(\.presentationMode) var presentationMode
    
    // Nuevo menú en construcción
    @State private var newMenu = Menu(
        name: "",
        description: "",
        price: 0.0,
        isDrinkIncluded: false,
        drinkDescription: "",
        isWaterIncluded: false,
        waterDescription: "",
        isBreadIncluded: false,
        breadDescription: "",
        isCoffeeIncluded: false,
        coffeeDescription: "",
        isWinePairingIncluded: false,
        winePairingDescription: "",
        mealType: "",
        associatedDishes: []
    )
    
    // Para gestionar los platos seleccionados al crear el menú
    @State private var selectedDishes: [Dish] = []
    
    // Para búsquedas y filtros
    @State private var searchText: String = ""
    @State private var selectedCategoryFilter: String = "Todos"
    @State private var selectedTypeFilter: String = "Todos"
    
    private let categoryFilterOptions = ["Todos", "Aperitivo", "Entrantes", "Segundos", "Postres"]
    private let typeFilterOptions = ["Todos", "Sin Gluten", "Vegano", "Vegetariano"]
    private let serviceOptions = ["Desayuno", "Almuerzo", "Cena"]
    
    // Cálculo del coste medio total
    var costAvgTotal: Double {
        averageCostOfMenu(dishes: selectedDishes)
    }
    
    // Lógica de rentabilidad
    var rentability: (String, Color) {
        let costAvg = costAvgTotal
        guard newMenu.price > 0, costAvg > 0 else {
            return ("Selecciona platos para información de rentabilidad", .black)
        }
        let ratio = costAvg / newMenu.price
        if ratio <= 0.25 {
            return ("Rentabilidad alta (<= 25%)", .green)
        } else if ratio <= 0.30 {
            return ("Atención (<= 30%)", .orange)
        } else {
            return ("Alerta (> 30%)", .red)
        }
    }
    
    // Filtrado de platos
    var filteredDishes: [Dish] {
        dishes.filter { dish in
            let matchesCategory = (selectedCategoryFilter == "Todos" || dish.category == selectedCategoryFilter)
            let matchesType = (selectedTypeFilter == "Todos" || dish.types.contains(selectedTypeFilter))
            let matchesSearch = searchText.isEmpty
                || dish.title.localizedCaseInsensitiveContains(searchText)
                || dish.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesType && matchesSearch
        }
    }
    
    var unselectedDishes: [Dish] {
        filteredDishes.filter { dish in
            !selectedDishes.contains(where: { $0.id == dish.id })
        }
    }
    
    // Agrupaciones
    var groupedFilteredDishes: [String: [Dish]] {
        Dictionary(grouping: unselectedDishes, by: { $0.category })
    }
    var groupedSelectedDishes: [String: [Dish]] {
        Dictionary(grouping: selectedDishes, by: { $0.category })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Información del Menú
                    Section(header: Text("Información del menú:").font(.headline)) {
                        // Nombre del Menú
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre del Menú")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Introduce el nombre del menú", text: $newMenu.name)
                                .textFieldStyleWithBackground()
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Descripción del Menú
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Introduce la descripción", text: $newMenu.description)
                                .textFieldStyleWithBackground()
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Precio de venta
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Precio de venta PVP (€)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Introduce el PVP (€)", value: $newMenu.price, format: .number)
                                .textFieldStyleWithBackground()
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                        }
                        
                        // Rentabilidad
                        let (msg, color) = rentability
                        Text(msg)
                            .foregroundColor(color)
                            .font(.footnote)
                            .padding(.top, 2)
                        
                        // Tipo de servicio
                        Picker("Tipo de servicio", selection: $newMenu.mealType) {
                            ForEach(serviceOptions, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                    }

                    
                    // Coste promedio del menú
                    if costAvgTotal > 0 {
                        Text(String(format: "Coste promedio del menú: %.2f €", costAvgTotal))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    
                    // Opciones Incluidas
                    Section(header: Text("Opciones incluidas:").font(.headline)) {
                        Toggle("Bebida incluida", isOn: $newMenu.isDrinkIncluded)
                            .onChange(of: newMenu.isDrinkIncluded) {
                                if newMenu.isDrinkIncluded && newMenu.drinkDescription.isEmpty {
                                    newMenu.drinkDescription = "Incluye una bebida (vino, cerveza, agua o refresco)."
                                }
                            }
                        if newMenu.isDrinkIncluded {
                            TextField("Descripción de la bebida", text: $newMenu.drinkDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 20)
                        }
                        
                        Toggle("Agua incluida", isOn: $newMenu.isWaterIncluded)
                            .onChange(of: newMenu.isWaterIncluded) {
                                if newMenu.isWaterIncluded && newMenu.waterDescription.isEmpty {
                                    newMenu.waterDescription = "Agua embotellada o filtrada incluida."
                                }
                            }
                        if newMenu.isWaterIncluded {
                            TextField("Descripción del agua", text: $newMenu.waterDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 20)
                        }
                        
                        Toggle("Pan incluido", isOn: $newMenu.isBreadIncluded)
                            .onChange(of: newMenu.isBreadIncluded) {
                                if newMenu.isBreadIncluded && newMenu.breadDescription.isEmpty {
                                    newMenu.breadDescription = "Servicio de pan incluido."
                                }
                            }
                        if newMenu.isBreadIncluded {
                            TextField("Descripción del pan", text: $newMenu.breadDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 20)
                        }
                        
                        Toggle("Café incluido", isOn: $newMenu.isCoffeeIncluded)
                            .onChange(of: newMenu.isCoffeeIncluded) {
                                if newMenu.isCoffeeIncluded && newMenu.coffeeDescription.isEmpty {
                                    newMenu.coffeeDescription = "Incluye un café al finalizar la comida."
                                }
                            }
                        if newMenu.isCoffeeIncluded {
                            TextField("Descripción del café", text: $newMenu.coffeeDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 20)
                        }
                        
                        Toggle("Maridaje incluido", isOn: $newMenu.isWinePairingIncluded)
                            .onChange(of: newMenu.isWinePairingIncluded) {
                                if newMenu.isWinePairingIncluded && newMenu.winePairingDescription.isEmpty {
                                    newMenu.winePairingDescription = "Maridaje de vinos recomendado para cada plato."
                                }
                            }
                        if newMenu.isWinePairingIncluded {
                            TextField("Descripción del maridaje", text: $newMenu.winePairingDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.leading, 20)
                        }
                    }
                    
                    // Platos Seleccionados
                    Section(header: Text("Platos seleccionados:").font(.headline)) {
                        if selectedDishes.isEmpty {
                            Text("Aún no has seleccionado ningún plato.")
                                .foregroundColor(.gray)
                        } else {
                            // ORDEN PERSONALIZADO
                            let desiredOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
                            let sortedCategories = groupedSelectedDishes.keys.sorted { cat1, cat2 in
                                let idx1 = desiredOrder.firstIndex(of: cat1) ?? Int.max
                                let idx2 = desiredOrder.firstIndex(of: cat2) ?? Int.max
                                return idx1 < idx2
                            }
                            
                            ForEach(sortedCategories, id: \.self) { category in
                                if let dishesInCategory = groupedSelectedDishes[category], !dishesInCategory.isEmpty {
                                    Section(header: Text(category)) {
                                        ForEach(dishesInCategory) { dish in
                                            HStack {
                                                Text("\(dish.title) \(formattedCost(dish.foodCost))")
                                                Spacer()
                                                Button(action: {
                                                    selectedDishes.removeAll { $0.id == dish.id }
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Búsqueda y Filtros
                    Section(header: Text("Búsqueda de platos y filtros:").font(.headline)) {
                        TextField("Buscar plato...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Categoría", selection: $selectedCategoryFilter) {
                            ForEach(categoryFilterOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Picker("Tipo", selection: $selectedTypeFilter) {
                            ForEach(typeFilterOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Lista de platos no seleccionados
                    Section(header: Text("Seleccionar platos:").font(.headline)) {
                        // ORDEN PERSONALIZADO
                        let desiredOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
                        let sortedCategories = groupedFilteredDishes.keys.sorted { cat1, cat2 in
                            let idx1 = desiredOrder.firstIndex(of: cat1) ?? Int.max
                            let idx2 = desiredOrder.firstIndex(of: cat2) ?? Int.max
                            return idx1 < idx2
                        }
                        
                        if unselectedDishes.isEmpty {
                            Text("No hay platos disponibles para agregar.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(sortedCategories, id: \.self) { category in
                                if let dishesInCategory = groupedFilteredDishes[category], !dishesInCategory.isEmpty {
                                    Section(header: Text(category)) {
                                        ForEach(dishesInCategory) { dish in
                                            HStack {
                                                Text("\(dish.title) \(formattedCost(dish.foodCost))")
                                                Spacer()
                                                Button(action: {
                                                    selectedDishes.append(dish)
                                                }) {
                                                    Image(systemName: "plus.circle")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Guardar Menú
                    Button("Guardar menú") {
                        newMenu.associatedDishes = selectedDishes
                        menus.append(newMenu)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                }
                .padding()
                .background(Color(UIColor.systemGray6))
            }
            .navigationTitle("Añadir menú")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - EditMenuView con la lógica de coste medio + mensajes

struct EditMenuView: View {
    @Binding var menu: Menu
    @Binding var menus: [Menu]
    @Binding var dishes: [Dish]
    
    // Lista local de platos seleccionados (para editar)
    @State private var selectedDishes: [Dish] = []
    
    // Campos de búsqueda y filtros
    @State private var searchText: String = ""
    @State private var selectedCategoryFilter: String = "Todos"
    @State private var selectedTypeFilter: String = "Todos"
    
    // Para que "Tipo de servicio" no cambie de inmediato
    @State private var localServiceType: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    // Inicializamos con los datos del menú existente
    init(menu: Binding<Menu>,
         menus: Binding<[Menu]>,
         dishes: Binding<[Dish]>) {
        
        self._menu = menu
        self._menus = menus
        self._dishes = dishes
        
        // Sincronizamos los platos asociados que ya tuviera el menú
        self._selectedDishes = State(initialValue: menu.wrappedValue.associatedDishes)
        // Guardamos el tipo de servicio para editar
        self._localServiceType = State(initialValue: menu.wrappedValue.mealType)
    }
    
    // -------------------------------
    //   Cálculo de coste promedio
    // -------------------------------
    var costAvgTotal: Double {
        averageCostOfMenu(dishes: selectedDishes)
    }
    
    // Mensaje y color de rentabilidad
    var rentability: (String, Color) {
        let tempMenu = Menu(
            name: menu.name,
            description: menu.description,
            price: menu.price,
            isDrinkIncluded: menu.isDrinkIncluded,
            drinkDescription: menu.drinkDescription,
            isWaterIncluded: menu.isWaterIncluded,
            waterDescription: menu.waterDescription,
            isBreadIncluded: menu.isBreadIncluded,
            breadDescription: menu.breadDescription,
            isCoffeeIncluded: menu.isCoffeeIncluded,
            coffeeDescription: menu.coffeeDescription,
            isWinePairingIncluded: menu.isWinePairingIncluded,
            winePairingDescription: menu.winePairingDescription,
            mealType: menu.mealType,
            associatedDishes: selectedDishes
        )
        return rentabilityInfo(for: tempMenu)
    }
    
    // Opciones para los filtros
    let categoryFilterOptions = ["Todos", "Aperitivo", "Entrantes", "Segundos", "Postres"]
    let typeFilterOptions = ["Todos", "Sin Gluten", "Vegano", "Vegetariano"]
    let serviceOptions = ["Desayuno", "Almuerzo", "Cena"]
    
    // Filtrado de platos
    var filteredDishes: [Dish] {
        dishes.filter { dish in
            let matchesCategory = (selectedCategoryFilter == "Todos" || dish.category == selectedCategoryFilter)
            let matchesType = (selectedTypeFilter == "Todos" || dish.types.contains(selectedTypeFilter))
            let matchesSearch = searchText.isEmpty
                || dish.title.localizedCaseInsensitiveContains(searchText)
                || dish.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesType && matchesSearch
        }
    }
    
    // Mostramos solo los platos que aún no están en "selectedDishes"
    var unselectedDishes: [Dish] {
        filteredDishes.filter { dish in
            !selectedDishes.contains(where: { $0.id == dish.id })
        }
    }
    
    // Agrupaciones
    var groupedSelectedDishes: [String: [Dish]] {
        Dictionary(grouping: selectedDishes, by: { $0.category })
    }
    var groupedUnselectedDishes: [String: [Dish]] {
        Dictionary(grouping: unselectedDishes, by: { $0.category })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1) Información del Menú
                Section(header: Text("Información del menú:").font(.headline)) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre del menú").font(.subheadline).foregroundColor(.gray)
                        TextField("Introduce el nombre del menú", text: $menu.name)
                            .textFieldStyleWithBackground()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción").font(.subheadline).foregroundColor(.gray)
                        TextField("Introduce la descripción", text: $menu.description)
                            .textFieldStyleWithBackground()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Precio de venta PVP (€)").font(.subheadline).foregroundColor(.gray)
                        TextField("Introduce el PVP (€)", value: $menu.price, format: .number)
                            .textFieldStyleWithBackground()
                            .keyboardType(.decimalPad)
                    }
                    
                    // Mensaje de rentabilidad
                    let (msg, color) = rentability
                    Text(msg)
                        .foregroundColor(color)
                        .font(.footnote)
                    
                    // Mostrar el coste promedio si > 0
                    if costAvgTotal > 0 {
                        Text(String(format: "Coste promedio del menú: %.2f €", costAvgTotal))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                
                .onTapGesture {
                    UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                }
 
                
                // 2) Opciones Incluidas
                Section(header: Text("Opciones incluidas:").font(.headline)) {
                    Toggle("Bebida incluida", isOn: $menu.isDrinkIncluded)
                    if menu.isDrinkIncluded {
                        TextField("Descripción de la bebida", text: $menu.drinkDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 20)
                    }
                    
                    Toggle("Agua incluida", isOn: $menu.isWaterIncluded)
                    if menu.isWaterIncluded {
                        TextField("Descripción del agua", text: $menu.waterDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 20)
                    }
                    
                    Toggle("Pan incluido", isOn: $menu.isBreadIncluded)
                    if menu.isBreadIncluded {
                        TextField("Descripción del pan", text: $menu.breadDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 20)
                    }
                    
                    Toggle("Café incluido", isOn: $menu.isCoffeeIncluded)
                    if menu.isCoffeeIncluded {
                        TextField("Descripción del café", text: $menu.coffeeDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 20)
                    }
                    
                    Toggle("Maridaje incluido", isOn: $menu.isWinePairingIncluded)
                    if menu.isWinePairingIncluded {
                        TextField("Descripción del maridaje", text: $menu.winePairingDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 20)
                    }
                }
                
                // 3) Tipo de servicio
                Section(header: Text("Tipo de servicio:").font(.headline)) {
                    Picker("Selecciona una opción", selection: $localServiceType) {
                        ForEach(serviceOptions, id: \.self) { op in
                            Text(op).tag(op)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 4) Platos Seleccionados
                Section(header: Text("Platos seleccionados:").font(.headline)) {
                    if selectedDishes.isEmpty {
                        Text("Aún no has seleccionado ningún plato.")
                            .foregroundColor(.gray)
                    } else {
                        // ORDEN PERSONALIZADO
                        let desiredOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
                        let sortedSelectedCategories = groupedSelectedDishes.keys.sorted { cat1, cat2 in
                            let idx1 = desiredOrder.firstIndex(of: cat1) ?? Int.max
                            let idx2 = desiredOrder.firstIndex(of: cat2) ?? Int.max
                            return idx1 < idx2
                        }
                        
                        ForEach(sortedSelectedCategories, id: \.self) { category in
                            if let catDishes = groupedSelectedDishes[category] {
                                Section(header: Text(category)) {
                                    ForEach(catDishes) { dish in
                                        HStack {
                                            Text("\(dish.title) \(formattedCost(dish.foodCost))")
                                            Spacer()
                                            Button {
                                                selectedDishes.removeAll { $0.id == dish.id }
                                            } label: {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 5) Búsqueda y filtros
                Section(header: Text("Búsqueda de platos y filtros:").font(.headline)) {
                    TextField("Buscar plato...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Categoría", selection: $selectedCategoryFilter) {
                        ForEach(categoryFilterOptions, id: \.self) { c in
                            Text(c)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Tipo", selection: $selectedTypeFilter) {
                        ForEach(typeFilterOptions, id: \.self) { t in
                            Text(t)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 6) Lista de platos NO seleccionados
                Section(header: Text("Seleccionar platos:").font(.headline)) {
                    // ORDEN PERSONALIZADO
                    let desiredOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
                    let sortedUnselectedCategories = groupedUnselectedDishes.keys.sorted { cat1, cat2 in
                        let idx1 = desiredOrder.firstIndex(of: cat1) ?? Int.max
                        let idx2 = desiredOrder.firstIndex(of: cat2) ?? Int.max
                        return idx1 < idx2
                    }
                    
                    if unselectedDishes.isEmpty {
                        Text("No hay platos disponibles para agregar.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(sortedUnselectedCategories, id: \.self) { category in
                            if let catDishes = groupedUnselectedDishes[category] {
                                Section(header: Text(category)) {
                                    ForEach(catDishes) { dish in
                                        HStack {
                                            Text("\(dish.title) \(formattedCost(dish.foodCost))")
                                            Spacer()
                                            Button {
                                                selectedDishes.append(dish)
                                            } label: {
                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 7) Botones finales: Guardar, Eliminar, Duplicar
                Button {
                    // Sincronizamos el menú final con los platos y tipo de servicio local
                    menu.mealType = localServiceType
                    menu.associatedDishes = selectedDishes
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Guardar cambios")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                Button {
                    if let idx = menus.firstIndex(where: { $0.id == menu.id }) {
                        menus.remove(at: idx)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Eliminar menú")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                
                Button {
                    let duplicated = Menu(
                        name: menu.name + " (Copia)",
                        description: menu.description,
                        price: menu.price,
                        isDrinkIncluded: menu.isDrinkIncluded,
                        drinkDescription: menu.drinkDescription,
                        isWaterIncluded: menu.isWaterIncluded,
                        waterDescription: menu.waterDescription,
                        isBreadIncluded: menu.isBreadIncluded,
                        breadDescription: menu.breadDescription,
                        isCoffeeIncluded: menu.isCoffeeIncluded,
                        coffeeDescription: menu.coffeeDescription,
                        isWinePairingIncluded: menu.isWinePairingIncluded,
                        winePairingDescription: menu.winePairingDescription,
                        mealType: localServiceType,
                        associatedDishes: selectedDishes
                    )
                    menus.append(duplicated)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Duplicar menú")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
        }
        .navigationTitle("Editar menú")
    }
}

// MARK: - EventsView

import SwiftUI

struct EventsView: View {
    @Binding var events: [Event]
    
    @State private var isPresentingAddEventView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Encabezado: Título y botón perfectamente alineados
                HStack {
                    Text("Eventos")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        isPresentingAddEventView = true
                    }) {
                        Text("Añadir evento")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding([.leading, .trailing, .top]) // Espaciado superior
                
                if events.isEmpty {
                    // Mensaje si no hay eventos
                    Text("No hay eventos aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Listado de eventos agrupados por mes
                    List {
                        ForEach(groupedByMonth.keys.sorted(by: { $0 < $1 }), id: \.self) { month in
                            Section(header: Text(monthHeader(for: month))) {
                                ForEach(groupedByMonth[month] ?? []) { event in
                                    NavigationLink(destination: EditEventView(event: binding(for: event),
                                                                              events: $events)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            // 1) Poner el círculo y el nombre en la misma línea
                                            HStack {
                                                Circle()
                                                    .fill(statusColor(for: event.status))
                                                    .frame(width: 10, height: 10)
                                                
                                                Text(event.name)
                                                    .font(.headline)
                                            }
                                            
                                            // 2) Debajo, la info adicional
                                            Text("Fecha: \(formattedDate(event.date))")
                                                .font(.footnote)
                                                .foregroundColor(.blue)
                                            Text("Tipo de servicio: \(event.serviceType)")
                                                .font(.footnote)
                                            Text("Nº de comensales: \(event.numberOfGuests)")
                                                .font(.footnote)
                                        }
                                        .padding(.vertical, 5)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // Ocultamos la barra de navegación del NavigationView
            .navigationBarHidden(true)
            // Presentamos AddEventView
            .sheet(isPresented: $isPresentingAddEventView) {
                NavigationView {
                    AddEventView(events: $events)
                }
            }
        }
    }
    
    // MARK: - Funciones auxiliares
    
    /// Ordena los eventos por fecha.
    private var sortedEvents: [Event] {
        events.sorted { $0.date < $1.date }
    }
    
    /// Agrupa los eventos por el mes en formato "MMMM yyyy".
    private var groupedByMonth: [String: [Event]] {
        Dictionary(grouping: sortedEvents) { event in
            let formatter = DateFormatter()
            formatter.locale = Locale.current // Usa el idioma del dispositivo
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: event.date)
        }
    }
    
    /// Devuelve un título formateado para la sección del mes.
    private func monthHeader(for month: String) -> String {
        month.capitalized // "enero 2025" → "Enero 2025"
    }
    
    /// Devuelve la fecha formateada.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Usa el idioma del dispositivo
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Devuelve el `Binding<Event>` para un evento concreto.
    private func binding(for event: Event) -> Binding<Event> {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else {
            fatalError("Evento no encontrado")
        }
        return $events[index]
    }
    
    /// Devuelve el color de acuerdo con el estado actual del evento.
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Por enviar":
            return .red
        case "Por confirmar":
            return .orange
        case "Confirmado":
            return .green
        default:
            return .gray
        }
    }
}



// MARK: - EditEventView

import SwiftUI

struct EditEventView: View {
    @Binding var event: Event
    @Binding var events: [Event]
    
    @Environment(\.presentationMode) var presentationMode
    
    // Tres estados con su color, igual que en AddEventView
    private let stateItems: [(String, Color)] = [
        ("Por enviar",    .red),
        ("Por confirmar", .orange),
        ("Confirmado",    .green)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Info básica
                Section(header: Text("Información del evento").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre del evento")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Introduce el nombre del evento", text: $event.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción del evento")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Introduce la descripción del evento", text: $event.description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Estado con colorSegmentedPicker
                    Section(header: Text("Estado del evento:").font(.headline)) {
                        ColorSegmentedPicker(selection: $event.status, items: stateItems)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fecha del evento")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker(
                            "Selecciona la fecha y hora",
                            selection: $event.date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo de servicio")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Selecciona el tipo de servicio", selection: $event.serviceType) {
                            ForEach(["Desayuno", "Almuerzo", "Cena"], id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                .onTapGesture {
                    UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                }

                
                // Detalles adicionales
                Section(header: Text("Detalles adicionales:").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Número de comensales")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Stepper("Comensales: \(event.numberOfGuests)",
                                value: $event.numberOfGuests,
                                in: 1...500)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duración estimada")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Ejemplo: 2 horas", text: $event.estimatedDuration)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Precio mínimo (€)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Ejemplo: 30", value: $event.minPrice, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Precio máximo (€)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Ejemplo: 50", value: $event.maxPrice, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Observaciones adicionales:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $event.additionalNotes)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                
                // Botón: Guardar cambios
                Button {
                    // event se modifica en tiempo real, cerramos la vista
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Guardar cambios")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                // Eliminar evento
                Button {
                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                        events.remove(at: index)
                    }
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Eliminar evento")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                
                // Duplicar evento
                Button {
                    let duplicated = Event(
                        name: event.name + " (Copia)",
                        description: event.description,
                        date: event.date,
                        serviceType: event.serviceType,
                        numberOfGuests: event.numberOfGuests,
                        estimatedDuration: event.estimatedDuration,
                        minPrice: event.minPrice,
                        maxPrice: event.maxPrice,
                        additionalNotes: event.additionalNotes,
                        status: event.status
                    )
                    events.append(duplicated)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Duplicar evento")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
        }
        .navigationTitle("Editar evento")
    }
}


// MARK: - AddEventView

struct AddEventView: View {
    @Binding var events: [Event]
    
    
    // Campos para crear el evento
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var serviceType: String = "Desayuno"
    @State private var numberOfGuests: Int = 1
    @State private var estimatedDuration: String = ""
    @State private var minPrice: Double = 0.0
    @State private var maxPrice: Double = 0.0
    @State private var additionalNotes: String = ""

    @State private var status: String = "Por enviar"

    private let stateItems: [(String, Color)] = [
        ("Por enviar",    .red),
        ("Por confirmar", .orange),
        ("Confirmado",    .green)
    ]
    
    let serviceTypeOptions = ["Desayuno", "Almuerzo", "Cena"]
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Información del evento
                    Section(header: Text("Información del evento").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nombre del evento")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Introduce el nombre del evento", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción del evento")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Introduce la descripción del evento", text: $description)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Section(header: Text("Estado del evento:").font(.headline)) {
                            ColorSegmentedPicker(selection: $status, items: stateItems)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha del evento")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            DatePicker(
                                "Selecciona la fecha y hora",
                                selection: $date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de servicio")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Picker("Selecciona el tipo de servicio", selection: $serviceType) {
                                ForEach(serviceTypeOptions, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    .onTapGesture {
                        UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                    }
 
                    
                    // Detalles adicionales
                    Section(header: Text("Detalles adicionales").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Número de comensales")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Stepper("Comensales: \(numberOfGuests)", value: $numberOfGuests, in: 1...500)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duración estimada")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Ejemplo: 2 horas", text: $estimatedDuration)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                                Text("Precio mínimo (€)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                TextField("Ejemplo: 30", value: $minPrice, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                        }
                            
                        VStack(alignment: .leading, spacing: 8) {
                                Text("Precio máximo (€)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                TextField("Ejemplo: 50", value: $maxPrice, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Observaciones adicionales")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextEditor(text: $additionalNotes)
                                .frame(minHeight: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    
                    Button("Guardar evento") {
                        let newEvent = Event(
                            name: name,
                            description: description,
                            date: date,
                            serviceType: serviceType,
                            numberOfGuests: numberOfGuests,
                            estimatedDuration: estimatedDuration,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            additionalNotes: additionalNotes,
                            status: status
                        )
                        events.append(newEvent)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                }
                .padding()
                // FONDO GRIS para que coincida con el de Añadir/Editar Plato
                .background(Color(UIColor.systemGray6))
            }
            .navigationTitle("Añadir evento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - SettingsView

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Binding var settings: RestaurantSettings
    @State private var selectedPickerItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                // ============== CABECERA ==============
                HStack {
                    Text("Ajustes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    
                    // Botón (opcional): si quieres algo arriba a la derecha
                    // (por ej. "Cerrar", o "Guardar", etc.)
                    Button {
                        // acción
                    } label: {
                        Text("Guardar")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding([.leading, .trailing, .top])
                
                // ============== CONTENIDO PRINCIPAL ==============
                // Usamos ScrollView + VStack para organizar las secciones:
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Sección: Info
                        Section(header: Text("Información del Restaurante").font(.headline)) {
                            TextField("Nombre del restaurante", text: $settings.restaurantName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Eslogan del restaurante", text: $settings.restaurantSlogan)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Sección: Contacto
                        Section(header: Text("Contacto").font(.headline)) {
                            TextField("Correo electrónico", text: $settings.email)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Teléfono", text: $settings.phone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Sitio Web", text: $settings.website)
                                .keyboardType(.URL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Sección: Dirección
                        Section(header: Text("Dirección").font(.headline)) {
                            TextField("Calle", text: $settings.addressStreet)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Ciudad", text: $settings.addressCity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Código Postal", text: $settings.addressPostalCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("País", text: $settings.addressCountry)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Sección: Logo
                        Section(header: Text("Logo del restaurante").font(.headline)) {
                            if let logo = settings.logoImage {
                                Image(uiImage: logo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } else {
                                Text("No hay logo seleccionado.").foregroundColor(.gray)
                            }
                            
                            PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                                Text("Seleccionar logo").foregroundColor(.blue)
                            }
                            .onChange(of: selectedPickerItem) { _, newItem in
                                Task {
                                    do {
                                        if let data = try await newItem?.loadTransferable(type: Data.self) {
                                            settings.logoImage = UIImage(data: data)
                                        }
                                    } catch {
                                        print("Error al cargar la imagen: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        
                        .onTapGesture {
                            UIApplication.shared.endEditing() // Ocultar teclado al tocar fuera
                        }
                        
                        // Sección: Precios de coste
                        Section(header: Text("Precios de coste (Opciones incluidas)").font(.headline)) {
                            HStack {
                                Text("Bebida incluida")
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("", value: $settings.costIncludedDrink, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("€")
                                }
                            }
                            // Agua incluida
                            HStack {
                                Text("Agua incluida")
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("", value: $settings.costIncludedWater, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("€")
                                }
                            }
                            
                            // Pan incluido
                            HStack {
                                Text("Pan incluido")
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("", value: $settings.costIncludedBread, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("€")
                                }
                            }
                            
                            // Café incluido
                            HStack {
                                Text("Café incluido")
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("", value: $settings.costIncludedCoffee, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("€")
                                }
                            }
                            
                            // Maridaje incluido
                            HStack {
                                Text("Maridaje incluido")
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("", value: $settings.costIncludedWinePairing, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("€")
                                }
                            }
                        }
                        
                    }
                    .padding()
                }
                // Fondo gris
                .background(Color(UIColor.systemGray6))
                .navigationBarHidden(true)
            }
        }
    }
}




// MARK: - Corrección para onChange

extension Toggle {
    func onChangeCompat<Value>(
        of value: Value,
        perform action: @escaping (Value) -> Void
    ) -> some View where Value: Equatable {
        // Usamos la nueva versión con (oldValue, newValue)
        self.onChange(of: value) { _, newValue in
            // Llamamos a la acción original con el “nuevo valor”
            action(newValue)
        }
    }
}

// MARK: - Vista previa

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Esconder teclado

struct HideKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle()) // Para detectar toques fuera del contenido
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardOnTap())
    }
}



