import SwiftUI

struct EntryDetailView: View {
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
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: Entry(content: "今天有一点乱，但写下来之后好像轻了一点。"))
    }
}
