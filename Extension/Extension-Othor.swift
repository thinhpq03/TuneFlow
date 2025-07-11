//
//  Extension-Othor.swift
//  TUANNM_MUSIC_09
//
//  Created by Phạm Quý Thịnh on 5/11/24.
//

import Foundation
import UIKit
import AVFoundation

extension String {
    func convertTimeStringToSeconds() -> Float? {
        let components = self.components(separatedBy: ":")
        let numComponents = components.count

        if numComponents == 2 || numComponents == 3 {
            var totalSeconds: Float = 0.0

            if let minutes = Float(components[numComponents - 2]),
               let seconds = Float(components[numComponents - 1]) {
                totalSeconds = minutes * 60 + seconds

                if numComponents == 3, let hours = Float(components[0]) {
                    totalSeconds += hours * 3600
                }

                return totalSeconds
            }
        }

        return nil 
    }

    func isValidTimeString() -> Bool {
        let timeRegex = #"^(?:([0-1]?[0-9]|2[0-3]):)?([0-5][0-9]):([0-5][0-9])$"#

        let predicate = NSPredicate(format: "SELF MATCHES %@", timeRegex)
        return predicate.evaluate(with: self)
    }
}

extension String {
    func trimming() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Array where Element: Equatable {
    func indexOf(object: Element) -> Int? {
        return (self as NSArray).contains(object) ? (self as NSArray).index(of: object) : nil
    }
}

extension URL {
    func generateThumb() -> UIImage? {

        let asset = AVAsset(url: self)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: 300, height: 300)

        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch {
            print(error.localizedDescription)
            return nil
        }

    }
}

extension URLSession {
    func downloadFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = self.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "Download error", code: -1, userInfo: nil)))
                return
            }

            completion(.success(tempURL))
        }
        task.resume()
    }
}


extension UIColor {

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Data {
    /// Creates a new buffer by copying the buffer pointer of the given array.
    ///
    /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
    ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
    ///     data from the resulting buffer has undefined behavior.
    /// - Parameter array: An array with elements of type `T`.
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }

    /// Convert a Data instance to Array representation.
    func toArray<T>(type: T.Type) -> [T] where T: AdditiveArithmetic {
        var array = [T](repeating: T.zero, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

extension Array {
    /// Creates a new array from the bytes of the given unsafe data.
    ///
    /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
    ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
    ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
    /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
    ///     `MemoryLayout<Element>.stride`.
    /// - Parameter unsafeData: The data containing the bytes to turn into an array.
    init?(unsafeData: Data) {
        guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
#if swift(>=5.0)
        self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
#else
        self = unsafeData.withUnsafeBytes {
            .init(UnsafeBufferPointer<Element>(
                start: $0,
                count: unsafeData.count / MemoryLayout<Element>.stride
            ))
        }
#endif  // swift(>=5.0)
    }
}



