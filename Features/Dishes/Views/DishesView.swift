import SwiftUI

struct DishesView: View {
    @StateObject private var viewModel = DishesViewModel()
    @State private var isPresentingAddDishView = false
    
    let categoryOrder = ["Aperitivo", "Entrantes", "Segundos", "Postres"]
    
    var groupedDishes: [String: [Dish]] {
        Dictionary(grouping: viewModel.dishes, by: { $0.category })
    }
    
    var sortedCategories: [String] {
        categoryOrder.filter { groupedDishes.keys.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                if viewModel.dishes.isEmpty {
                    Text("No hay platos aún.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(sortedCategories, id: \.self) { category in
                            Section(header: Text(category)) {
                                ForEach(groupedDishes[category] ?? []) { dish in
                                    NavigationLink {
                                        EditDishView(dish: dish, viewModel: viewModel)
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
                AddDishView(viewModel: viewModel)
            }
        }
    }
}
