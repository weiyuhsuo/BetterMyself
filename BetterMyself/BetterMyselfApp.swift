import SwiftData
import SwiftUI

@main
struct BetterMyselfApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Entry.self)
    }
}
