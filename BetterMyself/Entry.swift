import Foundation
import SwiftData

@Model
final class Entry: Identifiable {
    var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date?

    init(content: String, createdAt: Date = .now, updatedAt: Date? = nil) {
        self.id = UUID()
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
