//
//  HomeVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit
import RealmSwift

class HomeVC: BaseVC {

    @IBOutlet var lbs: [UILabel]!
    @IBOutlet weak var addViewHeight: NSLayoutConstraint!
    @IBOutlet weak var playlistViewHeight: NSLayoutConstraint!

    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var playlistCLV: UICollectionView!
    @IBOutlet weak var recentlyCLV: UICollectionView!

    var musicList: [MP3File] = []
    var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        loadPlaylists()
        setupCLV()
        loadMusicData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addView.applyHorizontalFourColorGradient()

    }

    func setupView() {
        lbs.forEach {
            $0.font = UIFont.G_B(24)
        }
        addBtn.titleLabel?.font = UIFont.G_B(30)
        addViewHeight.constant = isIphone ? 140 : 200
        playlistViewHeight.constant = isIphone ? 200 : 350
        addView.layer.cornerRadius = 20
        addView.clipsToBounds = true
    }

    func setupCLV() {
        playlistCLV.register(PagerCell.nibClass, forCellWithReuseIdentifier: PagerCell.cellId)
        playlistCLV.delegate = self
        playlistCLV.dataSource = self

        recentlyCLV.register(MusicCell.nibClass, forCellWithReuseIdentifier: MusicCell.cellId)
        recentlyCLV.dataSource = self
        recentlyCLV.delegate = self
    }

    func loadPlaylists() {
        let realm = try! Realm()
        let results = realm.objects(Playlist.self)
        playlists = Array(results)
        playlistCLV.reloadData()
    }
    
    func loadMusicData() {
        let realm = try! Realm()

        let results = realm.objects(MP3File.self)

        musicList = Array(results)
        recentlyCLV.reloadData()
    }

    @IBAction func addMusic(_ sender: Any) {
        let importVC = ImportVC()
        self.navigationController?.pushViewController(importVC, animated: true)
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentlyCLV {
            return musicList.count
        }
        return playlists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentlyCLV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCell.cellId, for: indexPath) as! MusicCell
            let music = musicList[indexPath.row]
            cell.configureCell(music: music, index: indexPath.row, isRecently: false)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagerCell.cellId, for: indexPath) as! PagerCell
        let playlist = playlists[indexPath.row]
        cell.configure(with: playlist)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recentlyCLV {
            let musicPlayerVC = MusicPlayerVC()
            musicPlayerVC.musicList = musicList
            musicPlayerVC.currentIndex = indexPath.row
            self.navigationController?.pushViewController(musicPlayerVC, animated: true)
        } else {
            let playlist = playlists[indexPath.row]
            let vc = ReviewPlaylistVC()
            vc.playlist = playlist
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - padding * 2 - (cell - 1) * spacing) / cell
        var height: CGFloat = 0
        if collectionView == recentlyCLV {
            height = width * 55 / 390
            return CGSize(width: width, height: height)
        }

        height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == recentlyCLV {
            return spacing
        }
        return padding * 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == recentlyCLV {
            return spacing
        }
        return padding * 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == recentlyCLV {
            return UIEdgeInsets(top: padding, left: padding, bottom: padding * 2, right: padding)
        }
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
}
