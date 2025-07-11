//
//  AllPlaylistMusicVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 26/5/25.
//

import UIKit

protocol AllPlaylistMusicDelegate: AnyObject {
    func didSelectMusic(at index: Int)
}

class AllPlaylistMusicVC: BaseVC {

    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var clv: UICollectionView!

    var musicList: [MP3File] = []
    weak var delegate: AllPlaylistMusicDelegate?
    private var expandedCellIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        titleLb.font = UIFont.G_B(24)
        clv.register(MusicCell.nibClass, forCellWithReuseIdentifier: MusicCell.cellId)
        clv.delegate = self
        clv.dataSource = self
    }

    @IBAction func closeTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AllPlaylistMusicVC: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicList.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: MusicCell.cellId, for: ip) as! MusicCell
        let music = musicList[ip.row]
        cell.configureCell(music: music, index: ip.row, isRecently: true)
        cell.isMore = (expandedCellIndex == ip.row)
        cell.onMore = { [weak self] in
            guard let self = self else { return }
            self.expandedCellIndex = (self.expandedCellIndex == ip.row) ? nil : ip.row
            self.clv.reloadData()
        }
        return cell
    }
}

extension AllPlaylistMusicVC: UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, didSelectItemAt ip: IndexPath) {
        delegate?.didSelectMusic(at: ip.row)
        dismiss(animated: true, completion: nil)
    }
}

extension AllPlaylistMusicVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt ip: IndexPath) -> CGSize {
        let width = (cv.frame.width - padding*2 - (cell-1)*spacing)/cell
        let height = width * 55/390
        return CGSize(width: width, height: height)
    }
    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
}
