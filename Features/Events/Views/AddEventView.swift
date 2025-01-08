import SwiftUI

struct AddEventView: View {
    @ObservedObject var viewModel: EventsViewModel
    
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
    
    let serviceTypeOptions = ["Desayuno", "Almuerzo", "Cena"]
    let statusOptions = ["Por enviar", "Por confirmar", "Confirmado"]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Nombre del evento", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Descripción del evento", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker("Fecha del evento", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    Picker("Tipo de servicio", selection: $serviceType) {
                        ForEach(serviceTypeOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Stepper("Comensales: \(numberOfGuests)", value: $numberOfGuests, in: 1...500)
                    
                    TextField("Duración estimada", text: $estimatedDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Precio mínimo (€)", value: $minPrice, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Precio máximo (€)", value: $maxPrice, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextEditor(text: $additionalNotes)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    
                    Picker("Estado", selection: $status) {
                        ForEach(statusOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
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
                        viewModel.addEvent(newEvent)
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
            .navigationTitle("Añadir evento")
        }
    }
}
