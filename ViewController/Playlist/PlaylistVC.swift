//
//  PlaylistVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 20/3/25.
//

import UIKit
import RealmSwift

class PlaylistVC: BaseVC {

    @IBOutlet weak var randomImg: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var playlistLb: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var playlistCLV: UICollectionView!

    var playlists: [Playlist] = []
    let defaultImage = UIImage(named: "nodata")

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        loadPlaylists()
        updateRandomImage()
    }

    func setupView() {
        randomImg.layer.cornerRadius = 10
        titleLb.font = UIFont.G_B(24)
        playlistLb.font = UIFont.G_B(19)
        addBtn.titleLabel?.font = UIFont.G_R(15)

        playlistCLV.register(PlaylistCell.nibClass, forCellWithReuseIdentifier: PlaylistCell.cellId)
        playlistCLV.delegate = self
        playlistCLV.dataSource = self
    }

    func loadPlaylists() {
        let realm = try! Realm()
        let results = realm.objects(Playlist.self)
        playlists = Array(results)
        playlistCLV.reloadData()
    }

    func updateRandomImage() {
        let playlistsWithImage = playlists.filter { $0.imageData != nil }
        if let randomPlaylist = playlistsWithImage.randomElement(),
           let data = randomPlaylist.imageData,
           let image = UIImage(data: data) {
            randomImg.image = image
        } else {
            randomImg.image = defaultImage
            randomImg.contentMode = .scaleAspectFit
        }
    }

    @IBAction func addPlaylist(_ sender: Any) {
        let createVC = CreatePlaylistVC()
        self.navigationController?.pushViewController(createVC, animated: true)
    }
}

extension PlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.cellId, for: indexPath) as! PlaylistCell
        let playlist = playlists[indexPath.row]
        cell.configure(with: playlist)
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            let playlistToDelete = self.playlists[indexPath.row]
            let realm = try! Realm()
            try! realm.write { realm.delete(playlistToDelete) }
            self.playlists.remove(at: indexPath.row)
            self.playlistCLV.deleteItems(at: [indexPath])
            self.updateRandomImage()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let vc = ReviewPlaylistVC()
        vc.playlist = playlist
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }

            let playlistToDelete = self.playlists[indexPath.row]

            let realm = try! Realm()
            try! realm.write {
                realm.delete(playlistToDelete)
            }

            self.playlists.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])

            self.updateRandomImage()

            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

extension PlaylistVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - padding * 2 - (cell - 1) * spacing) / cell
        let height = width * 170 / 355
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding * 2, right: padding)
    }
}
