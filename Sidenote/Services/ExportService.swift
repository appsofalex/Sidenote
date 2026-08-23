import Foundation

enum ExportService {
    static func plainText(entries: [SidenoteEntry]) -> String {
        let groups = StreamGrouping.groups(from: entries)
        var lines: [String] = ["Sidenote", ""]

        for group in groups {
            lines.append(SidenoteDates.heading(for: group.id).localizedCapitalized)
            lines.append("")
            for entry in group.entries {
                lines.append(SidenoteDates.time(entry.createdAt))
                lines.append(entry.text.trimmingCharacters(in: .whitespacesAndNewlines))
                lines.append("")
            }
        }

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
