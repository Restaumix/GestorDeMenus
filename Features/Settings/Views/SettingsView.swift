import SwiftUI
import PhotosUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var selectedPickerItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Section(header: Text("Información del Restaurante").font(.headline)) {
                        TextField("Nombre del restaurante", text: $viewModel.settings.restaurantName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Eslogan del restaurante", text: $viewModel.settings.restaurantSlogan)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Contacto").font(.headline)) {
                        TextField("Correo electrónico", text: $viewModel.settings.email)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Teléfono", text: $viewModel.settings.phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Sitio Web", text: $viewModel.settings.website)
                            .keyboardType(.URL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Dirección").font(.headline)) {
                        TextField("Calle", text: $viewModel.settings.addressStreet)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Ciudad", text: $viewModel.settings.addressCity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Código Postal", text: $viewModel.settings.addressPostalCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("País", text: $viewModel.settings.addressCountry)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Logo del Restaurante").font(.headline)) {
                        if let logo = viewModel.settings.logoImage {
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
                                        viewModel.settings.logoImage = UIImage(data: data)
                                    }
                                } catch {
                                    print("Error al cargar la imagen: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Costes Incluidos").font(.headline)) {
                        HStack {
                            Text("Bebida incluida")
                            Spacer()
                            TextField("€", value: $viewModel.settings.costIncludedDrink, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                        HStack {
                            Text("Agua incluida")
                            Spacer()
                            TextField("€", value: $viewModel.settings.costIncludedWater, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                        HStack {
                            Text("Pan incluido")
                            Spacer()
                            TextField("€", value: $viewModel.settings.costIncludedBread, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                        HStack {
                            Text("Café incluido")
                            Spacer()
                            TextField("€", value: $viewModel.settings.costIncludedCoffee, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                        HStack {
                            Text("Maridaje incluido")
                            Spacer()
                            TextField("€", value: $viewModel.settings.costIncludedWinePairing, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                    }
                    
                    Button("Guardar ajustes") {
                        viewModel.saveSettings()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Ajustes")
        }
    }
}
