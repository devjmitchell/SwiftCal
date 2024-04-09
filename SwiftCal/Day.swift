//
//  Day.swift
//  SwiftCal
//
//  Created by Jason Mitchell on 4/9/24.
//
//

import Foundation
import SwiftData


@Model class Day {
    var date: Date
    var didStudy: Bool
    
    init(date: Date, didStudy: Bool) {
        self.date = date
        self.didStudy = didStudy
    }
}
