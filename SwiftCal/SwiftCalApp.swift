//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Jason Mitchell on 4/4/24.
//

import SwiftUI

@main
struct SwiftCalApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                
                StreakView()
                    .tabItem { Label("Streak", systemImage: "swift") }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
