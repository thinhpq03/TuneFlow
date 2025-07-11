//
//  PlaylistCell.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 20/3/25.
//

import UIKit

class PlaylistCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var imgBg: UIView!

    var onDelete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        name.font = UIFont.G_B(14)
        desc.font = UIFont.G_R(12)
        imgBg.layer.cornerRadius = 4
        imgBg.clipsToBounds = true
        imgBg.applyHorizontalFourColorGradient()
        self.layer.cornerRadius = 5
    }

    func configure(with playlist: Playlist) {
        name.text = playlist.name
        desc.text = playlist.desc
        if let data = playlist.imageData, let image = UIImage(data: data) {
            img.image = image
        } else {
            img.image = UIImage(named: "nodata")
        }
    }

    @IBAction func deleteTap(_ sender: Any) {
        onDelete?()
    }
    

}
