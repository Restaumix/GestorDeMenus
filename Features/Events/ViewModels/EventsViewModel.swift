import Foundation

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    init() {
        loadEvents()
    }
    
    func loadEvents() {
        if let savedEvents = PersistenceHelper.load([Event].self, from: "events.json") {
            events = savedEvents
        } else {
            events = []
        }
    }
    
    func saveEvents() {
        PersistenceHelper.save(events, to: "events.json")
    }
    
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func updateEvent(_ updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events[index] = updatedEvent
            saveEvents()
        }
    }
}
