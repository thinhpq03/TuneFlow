//
//  Storyboard.swift
//  TUANNM_MUSIC_09
//
//  Created by Phạm Quý Thịnh on 5/11/24.
//

import Foundation
import Toast_Swift
import UIKit
import SwiftUI

extension UIView {
    func applyHorizontalFourColorGradient() {
        self.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()

        // #76FAB5, #3FE1DF, #61BFE7, #839EEF
        let color1 = UIColor(hex: "76FAB5")
        let color2 = UIColor(hex: "3FE1DF")
        let color3 = UIColor(hex: "61BFE7")
        let color4 = UIColor(hex: "839EEF")

        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor, color4.cgColor]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)

        gradientLayer.frame = self.bounds

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIImage {
    func toURL() -> URL? {
        let fileName = UUID().uuidString + ".png"
        let tempURL = FileManagerService.shared.ArtworkFolder()?.appendingPathComponent(fileName) ?? FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        guard let data = self.pngData() else { return nil }
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing image to temp URL: \(error)")
            return nil
        }
    }
}

struct Storyboard {
    static let main = "Main"
    static let home = "home"
}

extension UIStoryboard {
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: Storyboard.main, bundle: nil)
    }

    static func initVC<T: UIViewController>() -> T {
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }

}

extension UIView {

    static func getXib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func displayToast(_ message: String) {
        guard let window = UIWindow.keyWindow else { return }

        var style = ToastStyle()
        style.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        window.hideAllToasts()
        window.makeToast(message, duration: 3.0, position: .top, style: style)
    }

    func applyBlackGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.init(hex: "7E7E7E").cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.frame = self.bounds

        if let oldLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldLayer.removeFromSuperlayer()
        }

        self.layer.insertSublayer(gradientLayer, at: 0)
    }


}

extension UIWindow {
    static var keyWindow: UIWindow? {

        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene.delegate as? SceneDelegate else { return nil }
        return sceneDelegate.window

    }
}

extension UIViewController {
    func presentCustomAlert(_ viewController: UIViewController, animated: Bool = true) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let customVCWidth: CGFloat = 300
        let customVCHeight: CGFloat = 200
        let customVCX = (UIScreen.main.bounds.width - customVCWidth) / 2
        let customVCY = (UIScreen.main.bounds.height - customVCHeight) / 2
        viewController.view.frame = CGRect(x: customVCX, y: customVCY, width: customVCWidth, height: customVCHeight)

        containerView.addSubview(viewController.view)
        window?.addSubview(containerView)

        viewController.view.layer.cornerRadius = 10
        viewController.view.clipsToBounds = true


        viewController.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        viewController.view.alpha = 0

        UIView.animate(withDuration: 0.3) {
            viewController.view.alpha = 1
            viewController.view.transform = CGAffineTransform.identity
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissCustomAlert))
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissCustomAlert(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.view?.alpha = 0
            sender.view?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            sender.view?.removeFromSuperview()
        }
    }

}

extension UIViewController {
    var insetTop: CGFloat {
        return 0
    }

    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIView {
    func showMsg(_ message: String) {
        guard let window = UIWindow.keyWindow else { return }

        window.hideAllToasts()
        window.makeToast(message, duration: 3.0, position: .top )
    }
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
}

extension UIImage {
    class func original(_ name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
    }
}

extension UIApplication {
    class func getTopController(base: UIViewController? = UIWindow.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopController(base: presented)
        }
        return base
    }
}

extension UIDevice {
    var is_iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension UIDevice {
    var is_iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UICollectionViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UIView {
    class var nibNameClass: String { return String(describing: self.self) }

    class var nibClass: UINib? {
        if Bundle.main.path(forResource: nibNameClass, ofType: "nib") != nil {
            return UINib(nibName: nibNameClass, bundle: nil)
        } else {
            return nil
        }
    }
}
