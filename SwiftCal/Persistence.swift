//
//  Persistence.swift
//  SwiftCal
//
//  Created by Jason Mitchell on 4/9/24.
//

import Foundation
import SwiftData

struct Persistence {
    static var container: ModelContainer = {
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.semperphoenix.SwiftCal")!.appendingPathComponent("SwiftCal.sqlite")
        let config = ModelConfiguration(url: sharedStoreURL)
        return try! ModelContainer(for: Day.self, configurations: config)
    }()
    
//    static var container: ModelContainer {
//        let container: ModelContainer = {
//            let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.semperphoenix.SwiftCal")!.appendingPathComponent("SwiftCal.sqlite")
//            let config = ModelConfiguration(url: sharedStoreURL)
//            return try! ModelContainer(for: Day.self, configurations: config)
//        }()
//        
//        return container
//    }
}
