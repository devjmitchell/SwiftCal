//
//  CalendarHeaderView.swift
//  SwiftCal
//
//  Created by Jason Mitchell on 4/5/24.
//

import SwiftUI

struct CalendarHeaderView: View {
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var font: Font = .body
    
    var body: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    CalendarHeaderView()
}
