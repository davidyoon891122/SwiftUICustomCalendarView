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
    @State var markedDates: Set<Date> = []
    
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
                        .font(.system(size: 12.0))
                        .foregroundStyle(symbol == "일" ? .red : .gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5.0)
        }
        .padding(.horizontal)
    }
    
    private var calendarGridView: some View {
        let daysInMonth = numberOfDays(in: month)
        let firstWeekday = firstWeekdayOfMonth(in: month) - 1 // 0-based index
        let totalDays = firstWeekday + daysInMonth
        let totalCellsNeeded = ((totalDays + 6) / 7) * 7 // 전체 셀 수를 7의 배수로 맞춤
        
        // 이전 달의 마지막 날 계산
        let previousMonthDate = previousMonth()
        let daysInPreviousMonth = numberOfDays(in: previousMonthDate)
        
        return VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(0 ..< totalCellsNeeded, id: \.self) { index in
                    if index < firstWeekday {
                        // 이전 달의 일자 표시
                        let day = daysInPreviousMonth - (firstWeekday - index - 1)
                        CellView(day: day, isCurrentMonth: false)
                    } else if index < firstWeekday + daysInMonth {
                        // 현재 달의 일자 표시
                        let day = index - firstWeekday + 1
                        let date = getDate(for: day - 1)
                        let marked = markedDates.contains(date)
                        
                        CellView(day: day, marked: marked)
                    } else {
                        // 다음 달의 일자 표시
                        let day = index - (firstWeekday + daysInMonth) + 1
                        CellView(day: day, isCurrentMonth: false)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private struct CellView: View {
        var day: Int
        var marked: Bool = false
        var isCurrentMonth: Bool = true
        
        init(day: Int, marked: Bool = false, isCurrentMonth: Bool = true) {
            self.day = day
            self.marked = marked
            self.isCurrentMonth = isCurrentMonth
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5.0)
                    .opacity(0)
                    .overlay {
                        Text(String(day))
                            .foregroundColor(isCurrentMonth ? .black : .gray)
                    }
                
                if marked && isCurrentMonth {
                    Circle()
                        .foregroundStyle(.blue.opacity(0.6))
                        .overlay {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: 32.0, height: 32.0)
            .disabled(!isCurrentMonth) // 현재 달이 아닌 일자는 터치 불가능
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
        formatter.dateFormat = "yyyy년 M월"
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
