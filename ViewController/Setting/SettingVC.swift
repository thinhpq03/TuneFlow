//
//  SettingVC.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 24/3/25.
//

import UIKit
import StoreKit

class SettingVC: BaseVC {

    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet var views: [UIView]!
    @IBOutlet var lbs: [UILabel]!
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var stViews: [UIStackView]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        views.forEach {
            $0.applyHorizontalFourColorGradient()
        }
    }

    func setupView() {
        titleLb.font = UIFont.G_B(24)
        lbs.forEach { $0.font = UIFont.G_B(16) }
        views.forEach {
            $0.layer.cornerRadius = 12
            $0.applyHorizontalFourColorGradient()
            $0.clipsToBounds = true
        }
        stViews.forEach{
            $0.layer.cornerRadius = 11
            $0.backgroundColor = UIColor.init(hex: "141118")
        }
    }

    @IBAction func share(_ sender: Any) {
        let shareText = "Download now https://apps.apple.com/us/app/id";
        let textToShare = [shareText] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func rate(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    SKStoreReviewController.requestReview()
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }


    @IBAction func privacy(_ sender: Any) {
    }

    @IBAction func term(_ sender: Any) {
    }
}
