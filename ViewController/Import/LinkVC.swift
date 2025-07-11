//
//  LinkVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit
import RealmSwift

class LinkVC: BaseVC {

    @IBOutlet weak var naviTitle: UILabel!
    @IBOutlet weak var lb: UILabel!
    @IBOutlet weak var textBg: UIView!
    @IBOutlet weak var linkTxt: UITextField!
    @IBOutlet weak var doneBtn: UIButton!

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        doneBtn.applyHorizontalFourColorGradient()
    }

    func setupView() {
        naviTitle.font = UIFont.G_B(24)
        lb.font = UIFont.G_B(16)
        textBg.layer.cornerRadius = 20
        linkTxt.attributedPlaceholder = NSAttributedString(string: "http://...mp3 or http://...mp4", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        doneBtn.layer.cornerRadius = 8
        doneBtn.titleLabel?.font = UIFont.G_B(14)
        doneBtn.clipsToBounds = true
    }

    func saveToRealm(title: String, artist: String = "Unknown", localPath: String, source: String = "Local", artworkURL: String? = nil) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let relativePath = URL(fileURLWithPath: localPath).path.replacingOccurrences(of: documentsDirectory.path, with: "")

        let mp3File = MP3File()
        mp3File.title = title
        mp3File.artist = artist
        mp3File.localPath = relativePath
        mp3File.source = source
        mp3File.artworkURL = artworkURL

        let realm = try! Realm()

        do {
            try realm.write {
                realm.add(mp3File)
            }
            print("Saved \(title) to Realm with relative path: \(relativePath)")
            self.view.showMsg("Saved \(title) successfully")
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error saving to Realm: \(error)")
            showAlert(message: "Failed to save file information.")
        }
    }
    func getDocumentsDirectory() -> URL {
        return FileManagerService.shared.MusicFolder() ?? FileManager.default.temporaryDirectory
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let link = linkTxt.text,
              let url = URL(string: link),
              link.lowercased().hasSuffix(".mp3") || link.lowercased().hasSuffix(".mp4") else {
            showAlert(message: "Invalid URL. Please provide a link ending with .mp3 or .mp4")
            return
        }

        URLSession.shared.downloadFile(from: url) { result in
            switch result {
                case .success(let tempURL):
                    let fileName = url.lastPathComponent
                    let documentsDir = self.getDocumentsDirectory()
                    let destinationURL = documentsDir.appendingPathComponent(fileName)

                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        do {
                            try FileManager.default.removeItem(at: destinationURL)
                            print("Removed existing file at \(destinationURL.lastPathComponent)")
                        } catch {
                            print("Error removing existing file: \(error)")
                            DispatchQueue.main.async {
                                self.showAlert(message: "Can't download file. Please try again later.")
                            }
                            return
                        }
                    }

                    do {
                        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                        DispatchQueue.main.async {
                            let title = fileName.replacingOccurrences(of: ".mp3", with: "")
                            let artist = "Unknown"
                            let source = "Local"
                            let artworkURL: String? = nil
                            self.saveToRealm(title: title,
                                             artist: artist,
                                             localPath: destinationURL.path,
                                             source: source,
                                             artworkURL: artworkURL)
                        }
                    } catch {
                        print("Error moving file: \(error)")
                        DispatchQueue.main.async {
                            self.showAlert(message: "Can't download file. Please try again later.")
                        }
                    }

                case .failure(let error):
                    print("Download error: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(message: "Save error: \(error.localizedDescription)")
                    }
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
