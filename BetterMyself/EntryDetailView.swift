import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: Entry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(DateFormatters.detailDate(for: entry.createdAt))
                    .font(.subheadline)
                    .foregroundStyle(Color.betterSecondaryText)

                Text(entry.content)
                    .font(.body)
                    .foregroundStyle(Color.betterText)
                    .lineSpacing(6)
                    .textSelection(.enabled)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .background(Color.betterBackground)
        .navigationTitle("这一刻")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        deleteEntry()
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.betterText)
                }
                .accessibilityLabel("更多选项")
            }
        }
    }

    private func deleteEntry() {
        modelContext.delete(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: Entry(content: "今天有一点乱，但写下来之后好像轻了一点。"))
    }
}
