import WidgetKit
import SwiftUI

struct ProgressEntry: TimelineEntry {
    let date: Date
    let today: Int
    let goal: Int
    let streak: Int
}

struct ProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressEntry { ProgressEntry(date: Date(), today: 0, goal: 10, streak: 0) }
    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(Date().addingTimeInterval(1800))))
    }
    private func entry() -> ProgressEntry {
        let data = UserDefaults(suiteName: "group.com.example.easyEnglish")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current = data?.string(forKey: "updatedDay") == formatter.string(from: Date())
        return ProgressEntry(date: Date(), today: current ? data?.integer(forKey: "today") ?? 0 : 0, goal: max(1, data?.integer(forKey: "goal") ?? 10), streak: current ? data?.integer(forKey: "streak") ?? 0 : 0)
    }
}

struct ProgressWidgetView: View {
    let entry: ProgressEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("easy english", systemImage: "square.stack.3d.up.fill").font(.headline).foregroundStyle(.purple)
            Text("\(entry.today) / \(entry.goal) сегодня").font(.title2.bold())
            ProgressView(value: Double(min(entry.today, entry.goal)), total: Double(entry.goal)).tint(.purple)
            Text("Серия: \(entry.streak) дн.").font(.caption).foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) { LinearGradient(colors: [.purple.opacity(0.12), .mint.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing) }
    }
}

@main
struct EasyEnglishWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EasyEnglishWidget", provider: ProgressProvider()) { entry in ProgressWidgetView(entry: entry) }
            .configurationDisplayName("Easy English")
            .description("Ваш маленький шаг к английскому каждый день.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
