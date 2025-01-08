import SwiftUI

struct MenusView: View {
    @StateObject private var viewModel = MenusViewModel()
    @State private var isPresentingAddMenuView = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Menús")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        isPresentingAddMenuView = true
                    }) {
                        Text("Añadir menú")
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding([.leading, .trailing, .top])
                
                if viewModel.menus.isEmpty {
                    Text("No hay menús aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.menus) { menu in
                            NavigationLink(destination: EditMenuView(menu: menu, viewModel: viewModel)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(menu.name)
                                            .font(.headline)
                                        Spacer()
                                        Text(String(format: "%.2f €", menu.price))
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    Text(menu.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isPresentingAddMenuView) {
                AddMenuView(viewModel: viewModel)
            }
        }
    }
}
