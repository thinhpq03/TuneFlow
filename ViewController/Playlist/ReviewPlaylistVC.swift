//
//  ReviewPlaylistVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import RealmSwift

class ReviewPlaylistVC: BaseVC {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var musicCLV: UICollectionView!

    var playlist = Playlist()
    var playlistMusic: [MP3File] = []

    var expandedCellIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaylistMusic()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        displayPlaylistInfo()
        loadPlaylistMusic()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let realm = try! Realm()
        try! realm.write {
            playlist.musicIDs.removeAll()
            for m in playlistMusic {
                playlist.musicIDs.append(m.id)
            }
        }
    }

    func setupView() {
        name.font = UIFont.G_BL(65)
        des.font = UIFont.G_R(12)

        musicCLV.register(MusicCell.nibClass, forCellWithReuseIdentifier: MusicCell.cellId)
        musicCLV.delegate = self
        musicCLV.dataSource = self
    }

    func displayPlaylistInfo() {
        name.text = playlist.name
        des.text = playlist.desc

        if let data = playlist.imageData, let image = UIImage(data: data) {
            img.image = image
        } else {
            img.image = UIImage(named: "nodata")
        }
    }

    func loadPlaylistMusic() {
        let realm = try! Realm()
        playlistMusic = []
        for musicID in playlist.musicIDs {
            if let music = realm.object(ofType: MP3File.self, forPrimaryKey: musicID) {
                playlistMusic.append(music)
            }
        }
        musicCLV.reloadData()
    }

    func deleteMusicFromPlaylist(withID id: String, completion: @escaping () -> Void) {
        let realm = try! Realm()
        try! realm.write {
            if let idx = playlist.musicIDs.firstIndex(of: id) {
                playlist.musicIDs.remove(at: idx)
            }
        }
        completion()
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
    

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ReviewPlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlistMusic.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCell.cellId, for: indexPath) as! MusicCell
        let music = playlistMusic[indexPath.row]
        cell.configureCell(music: music, index: indexPath.row, isRecently: true)
        cell.isMore = (expandedCellIndex == indexPath.row)

        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            let musicID = music.id
            deleteMusicFromPlaylist(withID: musicID) {
                DispatchQueue.main.async {
                    self.expandedCellIndex = nil
                    self.loadPlaylistMusic()
                }
            }
        }

        cell.onShare = { [weak self] in
            guard let self = self else { return }
            shareMusic(music, from: self)
        }

        cell.onMore = { [weak self] in
            guard let self = self else { return }
            if self.expandedCellIndex == indexPath.row {
                self.expandedCellIndex = nil
            } else {
                self.expandedCellIndex = indexPath.row
            }
            self.musicCLV.reloadData()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let musicPlayerVC = MusicPlayerVC()
        musicPlayerVC.musicList = playlistMusic
        musicPlayerVC.currentIndex = indexPath.row

        self.navigationController?.pushViewController(musicPlayerVC, animated: true)
    }
}

extension ReviewPlaylistVC: UICollectionViewDelegateFlowLayout {
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

extension ReviewPlaylistVC: MusicPickerDelegate {
    func didSelectMusic(_ music: MP3File) {
        if !playlistMusic.contains(where: { $0.id == music.id }) {
            playlistMusic.append(music)
            musicCLV.reloadData()
            self.view.showMsg("Successfully add: \(music.title)")
        } else {
            self.view.showMsg("This music is already in the playlist")
        }
    }
}
