
import SwiftUI

struct CalendarView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedMonth = Date()
    @State private var selectedDate: Date?
    @State private var showDayDetail = false
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private var datesWithTraces: Set<Date> {
        dataManager.datesWithTraces(in: selectedMonth)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Archive")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.adaptivePrimaryText)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMonth = Date()
                                selectedDate = calendar.startOfDay(for: Date())
                            }
                        } label: {
                            Text("Today")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.accent)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Month navigation
                    monthNavigator
                        .padding(.horizontal, 20)
                    
                    // Weekday header
                    weekdayHeader
                        .padding(.horizontal, 20)
                    
                    // Calendar grid
                    calendarGrid
                        .padding(.horizontal, 20)
                    
                    // Day preview
                    if let date = selectedDate {
                        dayPreview(for: date)
                            .padding(.horizontal, 20)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
            .background(Color.adaptiveBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showDayDetail) {
                if let date = selectedDate {
                    DayDetailView(date: date, dataManager: dataManager)
                }
            }
        }
    }
    
    // MARK: - Month Navigator
    
    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.adaptiveCardBackground)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptivePrimaryText)
                
                let count = tracesInMonth
                Text("\(count) \(count == 1 ? "trace" : "traces")")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.adaptiveCardBackground)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                    )
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var tracesInMonth: Int {
        guard let interval = calendar.dateInterval(of: .month, for: selectedMonth) else { return 0 }
        return dataManager.traces.filter { interval.contains($0.timestamp) }.count
    }
    
    // MARK: - Weekday Header
    
    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .frame(height: 30)
            }
        }
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        var symbols = formatter.veryShortWeekdaySymbols ?? []
        // Move Sunday to end
        if !symbols.isEmpty {
            let sunday = symbols.removeFirst()
            symbols.append(sunday)
        }
        return symbols
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!),
                        isToday: calendar.isDateInToday(date),
                        hasTraces: datesWithTraces.contains(calendar.startOfDay(for: date)),
                        tracesCount: dataManager.traces(for: date).count
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDate = date
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 50)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
        )
    }
    
    private var daysInMonth: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: selectedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: interval.start).weekday else {
            return []
        }
        
        var days: [Date?] = []
        
        // Empty cells at start (Monday as first day)
        let emptyDays = (firstWeekday + 5) % 7
        days.append(contentsOf: Array(repeating: nil, count: emptyDays))
        
        // Month days
        var currentDate = interval.start
        while currentDate < interval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    // MARK: - Day Preview
    
    private func dayPreview(for date: Date) -> some View {
        let traces = dataManager.traces(for: date)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayString(for: date))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                    
                    Text("\(traces.count) \(traces.count == 1 ? "trace" : "traces")")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
                
                Spacer()
                
                if !traces.isEmpty {
                    Button {
                        showDayDetail = true
                    } label: {
                        Text("Details")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            
            if traces.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(Color.adaptiveSecondaryText.opacity(0.4))
                        Text("No traces")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveSecondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                // Thumbnails
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(traces.prefix(10)) { trace in
                            MiniTraceCardView(trace: trace)
                        }
                        
                        if traces.count > 10 {
                            Text("+\(traces.count - 10)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveSecondaryText)
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.adaptiveBackground)
                                )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
        )
    }
    
    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, EEEE"
        return formatter.string(from: date)
    }
}


struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasTraces: Bool
    let tracesCount: Int
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundColor)
            
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                    .foregroundColor(textColor)
                
                // Trace indicator
                if hasTraces {
                    Circle()
                        .fill(isSelected ? Color.white : AppTheme.accent)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(height: 50)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppTheme.accent
        } else if isToday {
            return AppTheme.accent.opacity(0.15)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return AppTheme.accent
        } else if hasTraces {
            return Color.adaptivePrimaryText
        } else {
            return Color.adaptiveSecondaryText.opacity(0.6)
        }
    }
}


struct DayDetailView: View {
    let date: Date
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    private var traces: [TraceEntry] {
        dataManager.traces(for: date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(traces) { trace in
                        TraceCardView(
                            trace: trace,
                            tag: dataManager.tags.first { $0.icon == trace.tagIcon },
                            onDelete: {
                                withAnimation(.spring(response: 0.4)) {
                                    dataManager.deleteTrace(trace)
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .background(Color.adaptiveBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(dayTitle)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
    
    private var dayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView(dataManager: DataManager.shared)
}
