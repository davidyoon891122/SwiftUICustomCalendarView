//
//  CalendarView.swift
//  SwiftUICustomCalendar
//
//  Created by Davidyoon on 9/19/24.
//

import SwiftUI

struct CalendarView: View {
    
    @State var month: Date
    @State var offset: CGSize = CGSize()
    @State var clickedDates: Set<Date> = []
    
    var body: some View {
        VStack {
            headerView
            calendarGridView
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width < -100 {
                        changeMonth(by: 1)
                    } else if gesture.translation.width > 100 {
                        changeMonth(by: -1)
                    }
                    self.offset = CGSize()
                }
        )
    }
    
    
    private var headerView: some View {
        VStack {
            HStack {
                Text(month, formatter: Self.dateFormatter)
                    .bold()
                Spacer()
            }
            .padding()
            
            
            HStack {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .foregroundStyle(symbol == "일" ? .red : .gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5.0)
        }
    }
    
    private var calendarGridView: some View {
        let daysInMonth: Int = numberOfDays(in: month)
        let firstWeekday: Int = firstWeekdayOfMonth(in: month) - 1
        let previousMonthDays: Int = numberOfDays(in: previousMonth())
        
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                // 이전 달의 일자를 표시
                ForEach(0 ..< firstWeekday, id: \.self) { index in
                    let day = previousMonthDays - (firstWeekday - 1 - index)
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundStyle(Color.clear)
                        .overlay(
                            Text(String(day))
                                .foregroundColor(.gray)
                        )
                }
                
                // 현재 달의 일자를 표시
                ForEach(0 ..< daysInMonth, id: \.self) { index in
                    let date = getDate(for: index)
                    let day = index + 1
                    let clicked = clickedDates.contains(date)
                    
                    CellView(day: day, clicked: clicked)
                        .onTapGesture {
                            if clicked {
                                clickedDates.remove(date)
                            } else {
                                clickedDates.insert(date)
                            }
                        }
                }
            }
        }
    }
    
    private struct CellView: View {
        var day: Int
        var clicked: Bool = false
        
        init(day: Int, clicked: Bool) {
            self.day = day
            self.clicked = clicked
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5.0)
                    .opacity(0)
                    .overlay(Text(String(day)))
                    .foregroundStyle(.blue)
                
                if clicked {
                    Circle()
                        .foregroundStyle(.blue.opacity(0.6))
                        .overlay {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 32.0, height: 32.0)
        }
    }
    
}

private extension CalendarView {
    
    func getDate(for day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: startOfMonth())!
    }
    
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return Calendar.current.date(from: components)!
    }
    
    func numberOfDays(in date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
    
    func changeMonth(by value: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: value, to: month) {
            self.month = newMonth
        }
    }
    
    func previousMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: month)!
    }
    
}


extension CalendarView {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }()
    
    static var weekdaySymbols: [String] = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar.veryShortWeekdaySymbols
    }()
    
}

#Preview {
    CalendarView(month: Date())
}
