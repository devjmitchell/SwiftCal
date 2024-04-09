//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Jason Mitchell on 4/5/24.
//

import CoreData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    let viewContext = PersistenceController.shared.container.viewContext
    
    var dayFetchRequest: NSFetchRequest<Day> {
        let request = Day.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
        request.predicate = NSPredicate(format: "date BETWEEN { %@, %@ }",
                                        Date().startOfCalendarWithPrefixDays as CVarArg,
                                        Date().endOfMonth as CVarArg)
        
        return request
    }
    
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            completion(entry)
        } catch {
            print("Widget failed to fetch days in snapshot")
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
        } catch {
            print("Widget failed to fetch days in snapshot")
        }
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalWidgetEntryView : View {
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        HStack {
            VStack {
                Text("\(calculateStreakValue())")
                    .font(.system(size: 70, design: .rounded))
                    .bold()
                    .foregroundStyle(.orange)
                
                Text("day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                CalendarHeaderView(font: .caption)
                
                LazyVGrid(columns: columns, spacing: 7) {
                    ForEach(entry.days) { day in
                        if day.date!.monthInt != Date().monthInt {
                            Text("")
                        } else {
                            Text(day.date!.formatted(.dateTime.day()))
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
            .padding(.leading, 6)
        }
    }
    
    private func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else { return 0 }
        
        let nonFutureDays = entry.days.filter { $0.date!.dayInt <= Date().dayInt }
        
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else if day.date!.dayInt != Date().dayInt {
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
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track days you study Swift with streaks.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    SwiftCalWidget()
} timeline: {
    CalendarEntry(date: .now, days: [])
    CalendarEntry(date: .now, days: [])
}
