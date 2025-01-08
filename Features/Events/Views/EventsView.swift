import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    @State private var isPresentingAddEventView = false
    
    var body: some View {
        NavigationView {
            VStack {
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
                .padding([.leading, .trailing, .top])
                
                if viewModel.events.isEmpty {
                    Text("No hay eventos aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            NavigationLink(destination: EditEventView(event: event, viewModel: viewModel)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Circle()
                                            .fill(statusColor(for: event.status))
                                            .frame(width: 10, height: 10)
                                        
                                        Text(event.name)
                                            .font(.headline)
                                    }
                                    
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
            .navigationBarHidden(true)
            .sheet(isPresented: $isPresentingAddEventView) {
                AddEventView(viewModel: viewModel)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
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
