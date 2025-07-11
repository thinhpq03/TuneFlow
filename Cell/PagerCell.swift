//
//  PagerCell.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//

import UIKit

class PagerCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descrip: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        img.layer.cornerRadius = 8
        name.font = UIFont.G_B(12)
        descrip.font = UIFont.G_B(10)
    }

    func configure(with playlist: Playlist) {
        name.text = playlist.name
        descrip.text = playlist.desc
        if let data = playlist.imageData, let image = UIImage(data: data) {
            img.image = image
        } else {
            img.image = UIImage(named: "nodata")
        }
    }
}
