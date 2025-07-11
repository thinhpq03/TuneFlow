//
//  Extension-Font.swift
//  TUANNM_MV_25
//
//  Created by NghiaNT on 21/1/25.
//

import Foundation
import UIKit


extension UIFont {

    static func G_BL(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "GothicA1-Black", size: size)
    }

    static func G_B(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "GothicA1-Bold", size: size)
    }
    
    static func G_R(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "GothicA1-Regular", size: size)
    }

    static func G_SB(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "GothicA1-SemiBold", size: size)
    }

}
