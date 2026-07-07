import Foundation

struct CustomerItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String          // Customer
    var amount: Double         // Punches
    var date: Date             // Last visit
    var isComplete: Bool       // Reward earned
    var notes: String = ""
    var createdAt: Date = Date()
}
