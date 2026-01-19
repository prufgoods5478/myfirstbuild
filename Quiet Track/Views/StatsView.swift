
import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var isAppeared = false
    
    enum StatsPeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    private var filteredTraces: [TraceEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return dataManager.traces.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return dataManager.traces.filter { $0.timestamp >= monthAgo }
        case .all:
            return dataManager.traces
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Statistics")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    // Period
                    periodPicker
                        .padding(.horizontal, 20)
                    
                    // Summary
                    summaryCards
                        .padding(.horizontal, 20)
                    
                    // Charts
                    if !filteredTraces.isEmpty {
                        tagChartSection
                            .padding(.horizontal, 20)
                        
                        dailyChartSection
                            .padding(.horizontal, 20)
                        
                        periodChartSection
                            .padding(.horizontal, 20)
                    } else {
                        emptyState
                            .padding(.top, 60)
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
            .background(Color.adaptiveBackground)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6).delay(0.1)) {
                    isAppeared = true
                }
            }
        }
    }
    
    // MARK: - Period Picker
    
    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(selectedPeriod == period ? .white : Color.adaptiveSecondaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? AppTheme.accent : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        )
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "camera.fill",
                value: "\(filteredTraces.count)",
                label: "Traces",
                color: AppTheme.accent
            )
            
            StatCard(
                icon: "tag.fill",
                value: "\(Set(filteredTraces.map { $0.tagIcon }).count)",
                label: "Tags",
                color: Color(hex: "#FF6B6B") ?? .red
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(longestStreak)",
                label: "Streak",
                color: Color(hex: "#FFE66D") ?? .yellow
            )
        }
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 20)
    }
    
    private var longestStreak: Int {
        guard !filteredTraces.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let dates = Set(filteredTraces.map { calendar.startOfDay(for: $0.timestamp) }).sorted(by: >)
        
        var streak = 1
        var maxStreak = 1
        
        for i in 1..<dates.count {
            let diff = calendar.dateComponents([.day], from: dates[i], to: dates[i-1]).day ?? 0
            if diff == 1 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 1
            }
        }
        
        return maxStreak
    }
    
    // MARK: - Tag Chart
    
    private var tagChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Tags")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            let tagStats = tagStatistics
            
            if !tagStats.isEmpty {
                Chart(tagStats, id: \.tag.id) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Tag", item.tag.name)
                    )
                    .foregroundStyle(AppTheme.headerGradient)
                    .cornerRadius(6)
                }
                .frame(height: CGFloat(tagStats.count * 44))
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.adaptiveSecondaryText.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.adaptiveSecondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.adaptivePrimaryText)
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
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 20)
    }
    
    private var tagStatistics: [(tag: Tag, count: Int)] {
        var stats: [String: Int] = [:]
        for trace in filteredTraces {
            stats[trace.tagIcon, default: 0] += 1
        }
        
        return stats.compactMap { (icon, count) in
            if let tag = dataManager.tags.first(where: { $0.icon == icon }) {
                return (tag, count)
            }
            return nil
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }
    
    // MARK: - Daily Chart
    
    private var dailyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Days")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            let dailyData = dailyStatistics
            
            Chart(dailyData, id: \.date) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Traces", item.count)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accent.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day())
                        .foregroundStyle(Color.adaptiveSecondaryText)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.adaptiveSecondaryText.opacity(0.1))
                    AxisValueLabel()
                        .foregroundStyle(Color.adaptiveSecondaryText)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 12, y: 4)
        )
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 20)
    }
    
    private var dailyStatistics: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var stats: [Date: Int] = [:]
        
        for trace in filteredTraces {
            let day = calendar.startOfDay(for: trace.timestamp)
            stats[day, default: 0] += 1
        }
        
        let days: Int
        switch selectedPeriod {
        case .week: days = 7
        case .month: days = 30
        case .all: days = min(stats.count + 7, 30)
        }
        
        var result: [(date: Date, count: Int)] = []
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                result.append((date, stats[date] ?? 0))
            }
        }
        
        return result.reversed()
    }
    
    // MARK: - Period Chart
    
    private var periodChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time of Day")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            let periodData = periodStatistics
            
            Chart(periodData, id: \.period) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.period.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            
            // Legend
            HStack(spacing: 16) {
                ForEach(periodData, id: \.period) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.period.color)
                            .frame(width: 10, height: 10)
                        
                        Text(item.period.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveSecondaryText)
                        
                        Text("\(item.count)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color.adaptivePrimaryText)
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
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 20)
    }
    
    private var periodStatistics: [(period: DayPeriod, count: Int)] {
        var stats: [DayPeriod: Int] = [:]
        
        for trace in filteredTraces {
            stats[trace.dayPeriod, default: 0] += 1
        }
        
        return DayPeriod.allCases.map { ($0, stats[$0] ?? 0) }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(Color.adaptiveSecondaryText.opacity(0.4))
            
            Text("No data yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryText)
            
            Text("Add some traces\nto see your statistics")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText)
                .multilineTextAlignment(.center)
        }
    }
}


struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.adaptivePrimaryText)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
        )
    }
}

#Preview {
    StatsView(dataManager: DataManager.shared)
}
