//
//  ContentView.swift
//  SwiftUICustomCalendar
//
//  Created by Davidyoon on 9/19/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var text: String = ""
    var body: some View {
        CalendarView(month: Date())
    }
}

#Preview {
    ContentView()
}
