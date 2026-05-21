import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ComposeView()
                .tabItem {
                    Label("输入", systemImage: "square.and.pencil")
                }

            TimelineView()
                .tabItem {
                    Label("回看", systemImage: "clock")
                }
        }
        .tint(Color.betterPrimary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
