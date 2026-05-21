import Foundation

enum DateFormatters {
    static func sectionTitle(for date: Date) -> String {
        makeFormatter(dateStyle: .medium, timeStyle: .none).string(from: date)
    }

    static func entryTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func detailDate(for date: Date) -> String {
        makeFormatter(dateStyle: .long, timeStyle: .short).string(from: date)
    }

    private static func makeFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
}
