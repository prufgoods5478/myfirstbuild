import SwiftUI

struct FeedView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showAddTrace = false
    @State private var selectedDate = Date()
    @Namespace private var animation
    
    private var todayTraces: [TraceEntry] {
        dataManager.traces(for: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.adaptiveBackground
                    .ignoresSafeArea()
                
                if todayTraces.isEmpty {
                    VStack(spacing: 0) {
                        headerView
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        emptyStateView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.bottom, 100)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            headerView
                                .padding(.horizontal, 20)
                            
                            ForEach(Array(todayTraces.enumerated()), id: \.element.id) { index, trace in
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
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 0.8).combined(with: .opacity)
                                ))
                            }
                            
                            if !todayTraces.isEmpty {
                                dayStatsView
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                            }
                            
                            Spacer(minLength: 140)
                        }
                        .padding(.top, 10)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        dataManager.loadTraces()
                    }
                }
                
                addButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 110)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddTrace) {
                AddTraceView(dataManager: dataManager)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.adaptiveCardBackground)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                        )
                }
                
                Spacer()
                
                Text("TRACELOG")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Color.adaptivePrimaryText)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Calendar.current.isDateInToday(selectedDate) ? Color.adaptiveSecondaryText.opacity(0.3) : Color.adaptiveSecondaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.adaptiveCardBackground)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                        )
                }
                .disabled(Calendar.current.isDateInToday(selectedDate))
            }
            
            HStack {
                Text(dayTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptivePrimaryText)
                
                Spacer()
                
                Text("\(todayTraces.count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
                + Text(" traces")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
            }
            
            HStack(spacing: 8) {
                ForEach(DayPeriod.allCases, id: \.self) { period in
                    let count = dataManager.traces(for: period, on: selectedDate).count
                    
                    HStack(spacing: 4) {
                        Image(systemName: period.icon)
                            .font(.system(size: 10))
                        Text("\(count)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(count > 0 ? period.color : Color.adaptiveSecondaryText.opacity(0.5))
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private var dayTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: selectedDate)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(Color.adaptiveSecondaryText.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No traces yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptivePrimaryText)
                
                Text("Capture your first trace of the day")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText)
            }
            
            Button {
                showAddTrace = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Trace")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(AppTheme.headerGradient)
                )
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
            }
            .padding(.top, 10)
        }
    }
    
    private var dayStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Day Activity")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(spacing: 6) {
                ForEach(DayPeriod.allCases, id: \.self) { period in
                    let count = dataManager.traces(for: period, on: selectedDate).count
                    let maxCount = max(dataManager.periodStats(for: selectedDate).map { $0.count }.max() ?? 1, 1)
                    let height = max(CGFloat(count) / CGFloat(maxCount) * 40, count > 0 ? 8 : 4)
                    
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(count > 0 ? period.color : Color.adaptiveSecondaryText.opacity(0.2))
                            .frame(height: height)
                        
                        Image(systemName: period.icon)
                            .font(.system(size: 12))
                            .foregroundColor(count > 0 ? period.color : Color.adaptiveSecondaryText.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
        )
    }
    
    private var addButton: some View {
        Button {
            showAddTrace = true
        } label: {
            ZStack {
                Circle()
                    .fill(AppTheme.headerGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppTheme.accent.opacity(0.5), radius: 16, y: 8)
                
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(showAddTrace ? 0.9 : 1)
        .animation(.spring(response: 0.3), value: showAddTrace)
    }
}

#Preview {
    FeedView(dataManager: DataManager.shared)
}
