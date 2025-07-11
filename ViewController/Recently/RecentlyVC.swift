//
//  RecentlyVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import RealmSwift

protocol MusicPickerDelegate: AnyObject {
    func didSelectMusic(_ music: MP3File)
}

class RecentlyVC: BaseVC {

    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var lb: UILabel!
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var searchBg: UIView!

    var musicList: [MP3File] = []
    var expandedCellIndex: Int? = nil

    var isPickerMode: Bool = false
    weak var musicPickerDelegate: MusicPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMusicData(searchText: searchTxt.text)
    }

    func setupView() {
        lb.font = UIFont.G_B(24)
        searchBg.layer.cornerRadius = 10
        searchTxt.font = UIFont.G_B(16)
        searchTxt.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BEBEBD")])

        searchTxt.delegate = self
        searchTxt.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)

        clv.register(MusicCell.nibClass, forCellWithReuseIdentifier: MusicCell.cellId)
        clv.delegate = self
        clv.dataSource = self
    }

    func loadMusicData(searchText: String? = nil) {
        let realm = try! Realm()
        let results: Results<MP3File>
        if let text = searchText, !text.isEmpty {
            results = realm.objects(MP3File.self).filter("title CONTAINS[c] %@", text)
        } else {
            results = realm.objects(MP3File.self)
        }
        musicList = Array(results)
        expandedCellIndex = nil
        clv.reloadData()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func searchTextChanged(_ textField: UITextField) {
        loadMusicData(searchText: textField.text)
    }
}

extension RecentlyVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCell.cellId, for: indexPath) as! MusicCell
        let music = musicList[indexPath.row]
        cell.configureCell(music: music, index: indexPath.row, isRecently: true)

        cell.isMore = (expandedCellIndex == indexPath.row)

        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            let musicID = music.id
            deleteMusic(withID: musicID) {
                DispatchQueue.main.async {
                    self.expandedCellIndex = nil
                    self.loadMusicData(searchText: self.searchTxt.text)
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
            self.clv.reloadData()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMusic = musicList[indexPath.row]
        if isPickerMode {
            self.view.showMsg("\(selectedMusic.title) đã được chọn")
            musicPickerDelegate?.didSelectMusic(selectedMusic)
            self.dismiss(animated: true, completion: nil)
        } else {
            let musicPlayerVC = MusicPlayerVC()
            musicPlayerVC.musicList = musicList
            musicPlayerVC.currentIndex = indexPath.row
            self.navigationController?.pushViewController(musicPlayerVC, animated: true)
        }
    }
}

extension RecentlyVC: UICollectionViewDelegateFlowLayout {
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

extension RecentlyVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
