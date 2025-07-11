//
//  ImportVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit
import RealmSwift
import MediaPlayer

class ImportVC: BaseVC {

    @IBOutlet var btns: [UIButton]!
    @IBOutlet weak var naviTitle: UILabel!

    let mediaPicker = MPMediaPickerController(mediaTypes: .music)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMediaPicker()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        btns.forEach {
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = UIFont.G_B(18)
            $0.applyHorizontalFourColorGradient()
            $0.clipsToBounds = true
        }
        naviTitle.font = UIFont.G_B(24)
    }

    func setupMediaPicker() {
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.prompt = "Select songs to import into your library"
    }

    @IBAction func link(_ sender: Any) {
        let linkVC = LinkVC()
        self.navigationController?.pushViewController(linkVC, animated: true)
    }
    
    @IBAction func appleMusic(_ sender: Any) {
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    @IBAction func wifiTranfer(_ sender: Any) {
        let wifiTranferVC = WifiTranferVC()
        self.navigationController?.pushViewController(wifiTranferVC, animated: true)
    }


    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ImportVC: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)

        let realm = try! Realm()

        for item in mediaItemCollection.items {
            guard let title = item.title else { continue }
            let artist = item.artist ?? "Unknown"
            let album = item.albumTitle
            let artworkURL = item.artwork?.image(at: CGSize(width: 100, height: 100))?.toURL()?.absoluteString
            let assetURL = item.assetURL?.absoluteString

            let mp3File = MP3File()
            mp3File.title = title
            mp3File.artist = artist
            mp3File.album = album
            mp3File.source = "Apple Music"
            mp3File.artworkURL = artworkURL
            mp3File.localPath = assetURL

            do {
                try realm.write {
                    realm.add(mp3File)
                }
                print("Saved \(title) from Apple Music to Realm")
            } catch {
                print("Error saving to Realm: \(error)")
            }
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

