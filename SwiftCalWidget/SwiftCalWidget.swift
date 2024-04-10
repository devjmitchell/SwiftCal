//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Jason Mitchell on 4/5/24.
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }
    
    @MainActor func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        let entry = CalendarEntry(date: Date(), days: fetchDays())
        completion(entry)
    }
    
    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = CalendarEntry(date: Date(), days: fetchDays())
        let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
        completion(timeline)
    }
    
    @MainActor private func fetchDays() -> [Day] {
        let startDate = Date().startOfCalendarWithPrefixDays
        let endDate = Date().endOfMonth
        let predicate = #Predicate<Day> { $0.date >= startDate && $0.date < endDate }
        let descriptor = FetchDescriptor<Day>(predicate: predicate, sortBy: [.init(\.date)])
        
        let context = ModelContext(Persistence.container)
        return try! context.fetch(descriptor)
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: CalendarEntry
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumCalendarView(entry: entry, streakValue: calculateStreakValue())
            
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
            
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
            
        case .accessoryInline:
            Label("Streak - \(calculateStreakValue()) days", systemImage: "swift")
                .widgetURL(URL(string: "streak"))
            
        case .systemSmall, .systemLarge, .systemExtraLarge:
            EmptyView()
            
        @unknown default:
            EmptyView()
        }
    }
    
    private func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else { return 0 }
        
        let nonFutureDays = entry.days.filter { $0.date.dayInt <= Date().dayInt }
        
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else if day.date.dayInt != Date().dayInt {
                break
            }
        }
        
        return streakCount
    }
}

struct SwiftCalWidget: Widget {
    let kind: String = "SwiftCalWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track days you study Swift with streaks.")
        .supportedFamilies([.systemMedium,
                            .accessoryRectangular,
                            .accessoryCircular,
                            .accessoryInline])
    }
}

#Preview("systemMedium", as: .systemMedium) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
}

#Preview("accessoryCircular", as: .accessoryCircular) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
}

#Preview("accessoryInline", as: .accessoryInline) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
}

// MARK: - UI Components for widget sizes

private struct MediumCalendarView: View {
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    var streakValue: Int
    
    var today: Day {
        entry.days.filter { Calendar.current.isDate($0.date, inSameDayAs: .now) }.first ?? .init(date: .distantPast, didStudy: false)
    }
    
    var body: some View {
        HStack {
            VStack {
                Link(destination: URL(string: "streak")!) {
                    VStack {
                        Text("\(streakValue)")
                            .font(.system(size: 70, design: .rounded))
                            .bold()
                            .foregroundStyle(.orange)
                            .contentTransition(.numericText())
                        
                        Text("day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button(today.didStudy ? "Studied" : "Study",
                       systemImage: today.didStudy ? "checkmark.circle" : "book",
                       intent: ToggleStudyIntent(date: today.date))
                    .font(.caption)
                    .tint(today.didStudy ? .mint : .orange)
                    .controlSize(.small)
            }
            .frame(width: 90)
            
            Link(destination: URL(string: "calendar")!) {
                VStack {
                    CalendarHeaderView(font: .caption)
                    
                    LazyVGrid(columns: columns, spacing: 7) {
                        ForEach(entry.days) { day in
                            if day.date.monthInt != Date().monthInt {
                                Text("")
                            } else {
                                Text(day.date.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(day.didStudy ? .orange : .secondary)
                                    .background(
                                        Circle()
                                            .foregroundStyle(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                                            .scaleEffect(1.5)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.leading, 6)
        }
        .containerBackground(for: .widget) { }
    }
}

private struct LockScreenCircularView: View {
    var entry: CalendarEntry
    
    var currentCalendarDays: Int {
        entry.days.filter { $0.date.monthInt == Date().monthInt }.count
    }
    
    var daysStudied: Int {
        entry.days.filter { $0.date.monthInt == Date().monthInt }.filter { $0.didStudy }.count
    }
    
    var body: some View {
        Gauge(value: Double(daysStudied), in: 1...Double(currentCalendarDays)) {
            Image(systemName: "swift")
        } currentValueLabel: {
            Text("\(daysStudied)")
        }
        .gaugeStyle(.accessoryCircular)
    }
}

private struct LockScreenRectangularView: View {
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var today: Day {
        entry.days.filter { Calendar.current.isDate($0.date, inSameDayAs: .now) }.first ?? .init(date: .distantPast, didStudy: false)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(entry.days) { day in
                if day.date.monthInt != Date().monthInt {
                    Text("")
                } else if day.didStudy {
                    Image(systemName: "swift")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 7, height: 7)
                } else {
                    Text(day.date.formatted(.dateTime.day()))
                        .font(.system(size: 7))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .containerBackground(for: .widget) { }
    }
}
