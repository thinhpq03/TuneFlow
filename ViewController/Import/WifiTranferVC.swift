//
//  WifiTranferVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 20/3/25.
//

import UIKit
import RealmSwift
import GCDWebServer

class WifiTranferVC: BaseVC {


    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var linkLb: UILabel!
    @IBOutlet var lbs: [UILabel]!
    @IBOutlet weak var startstopBtn: UIButton!

    var webUploader: GCDWebUploader?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        startWebServer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        DispatchQueue.main.async { [weak self] in
            if let webUploader = self?.webUploader, webUploader.isRunning {
                webUploader.stop()
                print("Server stopped")
            }
        }
    }

    func setupView() {
        titleLb.font = UIFont.G_B(24)
        lbs.forEach { $0.font = UIFont.G_B(16) }
        startstopBtn.layer.cornerRadius = 8
        startstopBtn.applyHorizontalFourColorGradient()
        startstopBtn.clipsToBounds = true
        startstopBtn.titleLabel?.font = UIFont.G_B(16)
    }

    override func showAlert(message: String) {
        let alert = UIAlertController(title: "Wifi Transfer", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func startWebServer() {
        guard let documentsPath = FileManagerService.shared.MusicFolder() else {
            DispatchQueue.main.async {
                self.view.showMsg("Something wrong!")
            }
            return
        }

        DispatchQueue.main.async {
            self.webUploader = GCDWebUploader(uploadDirectory: documentsPath.path)
            self.webUploader?.delegate = self
            self.webUploader?.allowHiddenItems = false

            let started = self.webUploader?.start(withPort: 8080, bonjourName: "TuneFlow Wifi Transfer")
            if started == true, let serverURL = self.webUploader?.serverURL {
                print("Server started at: \(serverURL)")
                self.linkLb.text = "\(serverURL)"
            } else {
                self.view.showMsg("Failed to start the server.")
            }
        }
    }

    func saveToRealm(title: String, artist: String, localPath: String, source: String, artworkURL: String?) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let relativePath = URL(fileURLWithPath: localPath).path.replacingOccurrences(of: documentsDirectory.path, with: "")

                let mp3File = MP3File()
                mp3File.title = title
                mp3File.artist = artist
                mp3File.localPath = relativePath
                mp3File.source = source
                mp3File.artworkURL = artworkURL
                mp3File.dateAdded = Date()

                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(mp3File)
                    }
                    print("Saved \(title) to Realm with relative path: \(relativePath)")

                    DispatchQueue.main.async {
                        self.view.showMsg("\(title) saved to library")
                    }
                } catch {
                    print("Error saving to Realm: \(error)")
                }
            }
        }
    }

    @IBAction func copyLink(_ sender: Any) {
        guard let textToCopy = linkLb.text, !textToCopy.isEmpty else {
            self.view.showMsg("Failed to copy link")
            return
        }

        UIPasteboard.general.string = textToCopy

        self.view.showMsg("Link copied to clipboard!")
    }
    
    @IBAction func startStop(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.webUploader?.isRunning == true {
                self.webUploader?.stop()
                self.startstopBtn.setTitle("Start Webserver", for: .normal)
            } else {
                self.startWebServer()
                self.startstopBtn.setTitle("Stop Webserver", for: .normal)
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension WifiTranferVC: GCDWebUploaderDelegate {
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        print("File uploaded: \(path)")

        let fileName = (path as NSString).lastPathComponent
        let title = fileName.replacingOccurrences(of: ".mp3", with: "")
        let artist = "Unknown"
        let localPath = path
        let source = "Wifi Transfer"

        saveToRealm(title: title, artist: artist, localPath: localPath, source: source, artworkURL: nil)
    }
}
