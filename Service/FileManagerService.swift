//
//  JewelryFolder.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 20/3/25.
//


import Foundation
import AVFoundation
import CoreImage

enum TuneFlow: String {
    case music_file
    case playlist_file
    case artwork_file
}


class FileManagerService: NSObject {
    static let shared = FileManagerService()

    func deleteFile(at url: URL, completion: @escaping ((Error?) -> Void)) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func cache() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func document() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }

    func MusicFolder() -> URL? {
        return self.createFolder(folderName: TuneFlow.music_file.rawValue)
    }

    func PlaylistFolder() -> URL? {
        return self.createFolder(folderName: TuneFlow.playlist_file.rawValue)
    }

    func ArtworkFolder() -> URL? {
        return self.createFolder(folderName: TuneFlow.artwork_file.rawValue)
    }

    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }

}


