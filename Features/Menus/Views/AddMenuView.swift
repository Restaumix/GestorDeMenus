import SwiftUI

struct AddMenuView: View {
    @ObservedObject var viewModel: MenusViewModel
    @State private var menu = Menu(
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
        mealType: ""
    )
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Nombre del menú", text: $menu.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Descripción del menú", text: $menu.description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Precio (€)", value: $menu.price, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Bebida incluida", isOn: $menu.isDrinkIncluded)
                    if menu.isDrinkIncluded {
                        TextField("Descripción de la bebida", text: $menu.drinkDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Agua incluida", isOn: $menu.isWaterIncluded)
                    if menu.isWaterIncluded {
                        TextField("Descripción del agua", text: $menu.waterDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Pan incluido", isOn: $menu.isBreadIncluded)
                    if menu.isBreadIncluded {
                        TextField("Descripción del pan", text: $menu.breadDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Café incluido", isOn: $menu.isCoffeeIncluded)
                    if menu.isCoffeeIncluded {
                        TextField("Descripción del café", text: $menu.coffeeDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Toggle("Maridaje incluido", isOn: $menu.isWinePairingIncluded)
                    if menu.isWinePairingIncluded {
                        TextField("Descripción del maridaje", text: $menu.winePairingDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Guardar menú") {
                        viewModel.addMenu(menu)
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
            .navigationTitle("Añadir menú")
        }
    }
}
