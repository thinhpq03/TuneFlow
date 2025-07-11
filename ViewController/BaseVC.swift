//
//  BaseVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit
import RealmSwift
import Photos

public let isIphone: Bool = UIDevice.current.is_iPhone

class BaseVC: UIViewController {

    let cell: CGFloat = isIphone ? 1 : 2
    let padding: CGFloat = isIphone ? 25 : 40
    let spacing: CGFloat = isIphone ? 10 : 15

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hex: "141118")
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func deleteMusic(withID id: String, completion: (() -> Void)? = nil) {
        let realm = try! Realm()
        if let musicToDelete = realm.object(ofType: MP3File.self, forPrimaryKey: id) {
            do {
                try realm.write {
                    realm.delete(musicToDelete)
                }
                print("Deleted music with id: \(id)")
                completion?()
            } catch {
                print("Error deleting music: \(error)")
            }
        } else {
            print("Music with id \(id) not found")
            completion?()
        }
    }
    
    func shareMusic(_ music: MP3File, from viewController: UIViewController) {
        if let path = music.localPath, !path.isEmpty {
            let fileURL = URL(fileURLWithPath: path)
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                            y: viewController.view.bounds.midY,
                                            width: 0,
                                            height: 0)
            }
            viewController.present(activityVC, animated: true, completion: nil)
        } else {
            let shareText = "Check out this song: \(music.title) by \(music.artist)"
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                            y: viewController.view.bounds.midY,
                                            width: 0,
                                            height: 0)
            }
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }

    public func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                completion(true)
            case .denied, .restricted:
                completion(false)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion(status == .authorized)
                    }
                }
            @unknown default:
                completion(false)
        }
    }
}
