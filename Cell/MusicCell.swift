//
//  MusicCell.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit
import SDWebImage

class MusicCell: UICollectionViewCell {

    @IBOutlet weak var artWork: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var order: UILabel!
    @IBOutlet weak var artWorkBg: UIView!
    @IBOutlet weak var moreView: UIStackView!
    @IBOutlet weak var moreBtn: UIButton!
    
    var isMore: Bool = false {
        didSet {
            moreView.isHidden = !isMore
        }
    }

    var onDelete: (() -> Void)?
    var onShare: (() -> Void)?
    var onMore: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isMore = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        name.font = UIFont.G_B(14)
        author.font = UIFont.G_R(12)
        order.font = UIFont.G_B(12)
        artWorkBg.layer.cornerRadius = 4
        artWorkBg.clipsToBounds = true
        artWorkBg.applyHorizontalFourColorGradient()
        moreView.layer.cornerRadius = 3
        moreView.clipsToBounds = true
    }

    func configureCell(music: MP3File, index: Int, isRecently: Bool) {
        name.text = music.title
        order.text = "\(index + 1)."
        author.text = music.artist
        moreBtn.isHidden = !isRecently
        if let artworkURL = music.artworkURL, let url = URL(string: artworkURL) {
            artWork.sd_setImage(with: url, placeholderImage: UIImage(named: "blank"))
        } else {
            artWork.image = UIImage(named: "blank")
        }
    }

    @IBAction func moreClick(_ sender: Any) {
        onMore?()
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        onDelete?()
    }
    
    @IBAction func shareClick(_ sender: Any) {
        onShare?()
    }
}
