import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [CustomerItem] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Seed data has 4 items; keep this well above that
    /// so a fresh install never hits the paywall immediately.
    static let freeLimit = 25

    private let fileName = "punchcard_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CustomerItem].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Self.freeLimit
    }

    @discardableResult
    func add(title: String, amount: Double, date: Date, isComplete: Bool, notes: String = "") -> Bool {
        guard canAddMore else { return false }
        let item = CustomerItem(title: title, amount: amount, date: date, isComplete: isComplete, notes: notes)
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: CustomerItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CustomerItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func toggleComplete(_ item: CustomerItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isComplete.toggle()
        save()
    }

    static func seedData() -> [CustomerItem] {
        [
        CustomerItem(title: "Jamie R.", amount: 7.0, date: Date(), isComplete: false, notes: "2 punches to free item"),
        CustomerItem(title: "Alex T.", amount: 10.0, date: Date(), isComplete: true, notes: "Reward redeemed"),
        CustomerItem(title: "Morgan L.", amount: 3.0, date: Date(), isComplete: false, notes: "New customer"),
        CustomerItem(title: "Sam K.", amount: 9.0, date: Date(), isComplete: false, notes: "Almost there")
        ]
    }
}
