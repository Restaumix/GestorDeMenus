import SwiftUI

struct AddDishView: View {
    @ObservedObject var viewModel: DishesViewModel
    
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
                        TextField("Título", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Descripción", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Picker("Categoría", selection: $selectedCategory) {
                            ForEach(categoryOptions, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        TextField("Coste de ingredientes (€)", text: $foodCost)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Alérgenos:").font(.headline)) {
                        ForEach(allergenOptions, id: \.self) { allergen in
                            Toggle(allergen, isOn: Binding(
                                get: { allergens.contains(allergen) },
                                set: { if $0 { allergens.insert(allergen) } else { allergens.remove(allergen) } }
                            ))
                        }
                    }
                    
                    Section(header: Text("Tipo de plato:").font(.headline)) {
                        ForEach(typeOptions, id: \.self) { type in
                            Toggle(type, isOn: Binding(
                                get: { types.contains(type) },
                                set: { if $0 { types.insert(type) } else { types.remove(type) } }
                            ))
                        }
                    }
                    
                    Button("Guardar plato") {
                        let newDish = Dish(
                            title: title,
                            description: description,
                            foodCost: Double(foodCost),
                            allergens: Array(allergens),
                            types: Array(types),
                            category: selectedCategory
                        )
                        viewModel.addDish(newDish)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Añadir plato")
        }
    }
}
