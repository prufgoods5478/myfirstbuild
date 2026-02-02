import Foundation
import SwiftUI
import UIKit

class PhotoManager {
    static let shared = PhotoManager()
    
    private let fileManager = FileManager.default
    
    private var photosDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDir = documentsDirectory.appendingPathComponent("TracePhotos", isDirectory: true)
        
        if !fileManager.fileExists(atPath: photosDir.path) {
            try? fileManager.createDirectory(at: photosDir, withIntermediateDirectories: true)
        }
        
        return photosDir
    }
    
    private init() {}
    
    func savePhoto(_ image: UIImage, quality: CGFloat = 0.8) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: quality) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            return nil
        }
    }
    
    func loadPhoto(from path: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(path)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func loadPhotoAsImage(from path: String) -> Image? {
        guard let uiImage = loadPhoto(from: path) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    func deletePhoto(at path: String) {
        let fileURL = photosDirectory.appendingPathComponent(path)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func createThumbnail(from image: UIImage, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let aspectRatio = image.size.width / image.size.height
        var thumbnailSize = size
        
        if aspectRatio > 1 {
            thumbnailSize.height = size.width / aspectRatio
        } else {
            thumbnailSize.width = size.height * aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail
    }
    
    func clearAllPhotos() {
        try? fileManager.removeItem(at: photosDirectory)
        _ = photosDirectory
    }
    
    func totalStorageUsed() -> Int64 {
        var totalSize: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    func formattedStorageUsed() -> String {
        let bytes = totalStorageUsed()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
