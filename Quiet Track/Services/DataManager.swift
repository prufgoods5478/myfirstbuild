import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var traces: [TraceEntry] = []
    @Published var tags: [Tag] = []
    @Published var isLoading = false
    
    private let tracesKey = "traces_data"
    private let tagsKey = "tags_data"
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var tracesFileURL: URL {
        documentsDirectory.appendingPathComponent("traces.json")
    }
    
    private var tagsFileURL: URL {
        documentsDirectory.appendingPathComponent("tags.json")
    }
    
    private init() {
        loadTags()
        loadTraces()
    }
    
    func loadTraces() {
        isLoading = true
        defer { isLoading = false }
        
        guard fileManager.fileExists(atPath: tracesFileURL.path) else {
            traces = []
            return
        }
        
        do {
            let data = try Data(contentsOf: tracesFileURL)
            traces = try JSONDecoder().decode([TraceEntry].self, from: data)
            traces.sort { $0.timestamp > $1.timestamp }
        } catch {
            traces = []
        }
    }
    
    func saveTraces() {
        do {
            let data = try JSONEncoder().encode(traces)
            try data.write(to: tracesFileURL)
        } catch {}
    }
    
    func addTrace(_ trace: TraceEntry) {
        traces.insert(trace, at: 0)
        saveTraces()
    }
    
    func deleteTrace(_ trace: TraceEntry) {
        PhotoManager.shared.deletePhoto(at: trace.photoPath)
        traces.removeAll { $0.id == trace.id }
        saveTraces()
    }
    
    func updateTrace(_ trace: TraceEntry) {
        if let index = traces.firstIndex(where: { $0.id == trace.id }) {
            traces[index] = trace
            saveTraces()
        }
    }
    
    func loadTags() {
        guard fileManager.fileExists(atPath: tagsFileURL.path) else {
            tags = Tag.defaultTags
            saveTags()
            return
        }
        
        do {
            let data = try Data(contentsOf: tagsFileURL)
            tags = try JSONDecoder().decode([Tag].self, from: data)
        } catch {
            tags = Tag.defaultTags
        }
    }
    
    func saveTags() {
        do {
            let data = try JSONEncoder().encode(tags)
            try data.write(to: tagsFileURL)
        } catch {}
    }
    
    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveTags()
    }
    
    func deleteTag(_ tag: Tag) {
        guard !tag.isDefault else { return }
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }
    
    func traces(for date: Date) -> [TraceEntry] {
        let calendar = Calendar.current
        return traces.filter {
            calendar.isDate($0.timestamp, inSameDayAs: date)
        }
    }
    
    func traces(for period: DayPeriod, on date: Date) -> [TraceEntry] {
        traces(for: date).filter { $0.dayPeriod == period }
    }
    
    func tracesThisWeek() -> [TraceEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return traces.filter { $0.timestamp >= weekAgo }
    }
    
    func tagStats(for date: Date? = nil) -> [(tag: Tag, count: Int)] {
        let filteredTraces = date != nil ? traces(for: date!) : traces
        
        var stats: [String: Int] = [:]
        for trace in filteredTraces {
            stats[trace.tagIcon, default: 0] += 1
        }
        
        return stats.compactMap { (icon, count) in
            if let tag = tags.first(where: { $0.icon == icon }) {
                return (tag, count)
            }
            return nil
        }.sorted { $0.count > $1.count }
    }
    
    func periodStats(for date: Date) -> [(period: DayPeriod, count: Int)] {
        DayPeriod.allCases.map { period in
            (period, traces(for: period, on: date).count)
        }
    }
    
    func datesWithTraces(in month: Date) -> Set<Date> {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: month)!
        
        return Set(traces
            .filter { interval.contains($0.timestamp) }
            .map { calendar.startOfDay(for: $0.timestamp) }
        )
    }
    
    func exportData() -> Data? {
        struct ExportData: Codable {
            let traces: [TraceEntry]
            let tags: [Tag]
            let exportDate: Date
        }
        
        let exportData = ExportData(traces: traces, tags: tags, exportDate: Date())
        return try? JSONEncoder().encode(exportData)
    }
    
    func importData(from data: Data) -> Bool {
        struct ExportData: Codable {
            let traces: [TraceEntry]
            let tags: [Tag]
            let exportDate: Date
        }
        
        guard let importedData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }
        
        traces = importedData.traces
        tags = importedData.tags
        
        saveTraces()
        saveTags()
        
        return true
    }
    
    func clearAllData() {
        for trace in traces {
            PhotoManager.shared.deletePhoto(at: trace.photoPath)
        }
        
        traces = []
        tags = Tag.defaultTags
        
        saveTraces()
        saveTags()
    }
}
