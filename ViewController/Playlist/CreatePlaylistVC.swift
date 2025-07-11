//
//  CreatePlaylistVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 20/3/25.
//

import UIKit
import RealmSwift

class CreatePlaylistVC: BaseVC {

    @IBOutlet weak var naviTitle: UILabel!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var desTxt: UITextField!
    @IBOutlet weak var addTxt: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var nameBg: UIView!
    @IBOutlet weak var desBg: UIView!
    

    var playlistMusicList: [MP3File] = []
    var expandedCellIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clv.reloadData()
    }

    func setupView() {
        naviTitle.font = UIFont.G_B(24)
        nameTxt.font = UIFont.G_BL(40)
        desTxt.font = UIFont.G_R(14)
        addTxt.font = UIFont.G_R(14)
        nameBg.layer.cornerRadius = 8
        desBg.layer.cornerRadius = 4

        nameTxt.attributedPlaceholder = NSAttributedString(string: "Name Playlist", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        desTxt.attributedPlaceholder = NSAttributedString(string: "Description", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BEBEBD")])

        clv.register(MusicCell.nibClass, forCellWithReuseIdentifier: MusicCell.cellId)
        clv.delegate = self
        clv.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func addImage(_ sender: Any) {
        checkPhotoLibraryPermission { authorized in
            if authorized {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.view.showMsg("Please grant access to photo library")
            }
        }
    }

    @IBAction func addMusic(_ sender: UIBarButtonItem) {
        let recentlyVC = RecentlyVC()
        recentlyVC.modalPresentationStyle = .popover
        recentlyVC.isPickerMode = true
        recentlyVC.musicPickerDelegate = self
        recentlyVC.preferredContentSize = CGSize(width: 650, height: 800)

        if let popoverPresentationController = recentlyVC.popoverPresentationController {
            popoverPresentationController.barButtonItem = sender
            popoverPresentationController.permittedArrowDirections = .any
        }

        present(recentlyVC, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        let playlistName = nameTxt.text ?? "Untitled"
        let playlistDesc = desTxt.text ?? ""
        let playlistImage = img.image
        let playlist = Playlist()
        playlist.id = UUID().uuidString
        playlist.name = playlistName
        playlist.desc = playlistDesc
        if let imageData = playlistImage?.jpegData(compressionQuality: 0.8) {
            playlist.imageData = imageData
        }
        for music in playlistMusicList {
            playlist.musicIDs.append(music.id)
        }
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(playlist)
            }
            self.view.showMsg("Playlist \"\(playlistName)\" saved")
            self.navigationController?.popViewController(animated: true)
        } catch {
            self.view.showMsg("Error saving playlist")
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreatePlaylistVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.img.image = image
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension CreatePlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlistMusicList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCell.cellId, for: indexPath) as! MusicCell
        let music = playlistMusicList[indexPath.row]
        cell.configureCell(music: music, index: indexPath.row, isRecently: false)

        cell.isMore = (expandedCellIndex == indexPath.row)
        
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.playlistMusicList.removeAll(where: { $0.id == music.id })
            self.clv.reloadData()
            self.expandedCellIndex = nil
            self.view.showMsg("Removed: \(music.title)")
        }

        cell.onMore = { [weak self] in
            guard let self = self else { return }
            if self.expandedCellIndex == indexPath.row {
                self.expandedCellIndex = nil
            } else {
                self.expandedCellIndex = indexPath.row
            }
            self.clv.reloadData()
        }

        return cell
    }
}

extension CreatePlaylistVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - padding * 2 - (cell - 1) * spacing) / cell
        let height = width * 55 / 390
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
}

extension CreatePlaylistVC: MusicPickerDelegate {
    func didSelectMusic(_ music: MP3File) {
        if !playlistMusicList.contains(where: { $0.id == music.id }) {
            playlistMusicList.append(music)
            clv.reloadData()
            self.view.showMsg("Successfully add: \(music.title)")
        } else {
            self.view.showMsg("This music is already in the playlist")
        }
    }
}
