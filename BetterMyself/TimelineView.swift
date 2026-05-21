import SwiftData
import SwiftUI

struct TimelineView: View {
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]

    private var sections: [EntrySection] {
        Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.createdAt)
        }
        .map { date, entries in
            EntrySection(date: date, entries: entries.sorted { $0.createdAt > $1.createdAt })
        }
        .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.betterBackground
                    .ignoresSafeArea()

                if entries.isEmpty {
                    ContentUnavailableView(
                        "这里还很安静",
                        systemImage: "tray",
                        description: Text("写下来的片段，会慢慢出现在这里")
                    )
                    .foregroundStyle(Color.betterSecondaryText)
                } else {
                    List {
                        ForEach(sections) { section in
                            Section(section.title) {
                                ForEach(section.entries) { entry in
                                    NavigationLink {
                                        EntryDetailView(entry: entry)
                                    } label: {
                                        EntryRow(entry: entry)
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("回看")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct EntrySection: Identifiable {
    let date: Date
    let entries: [Entry]

    var id: Date { date }

    var title: String {
        DateFormatters.sectionTitle(for: date)
    }
}

private struct EntryRow: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DateFormatters.entryTime(for: entry.createdAt))
                .font(.caption)
                .foregroundStyle(Color.betterSecondaryText)

            Text(entry.content)
                .font(.body)
                .foregroundStyle(Color.betterText)
                .lineLimit(3)
                .lineSpacing(3)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: Entry.self, inMemory: true)
}
