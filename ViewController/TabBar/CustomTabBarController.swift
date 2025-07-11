//
//  CustomTabBarController.swift
//  Jewelry
//
//  Created by Phạm Quý Thịnh on 13/3/25.
//


import UIKit

class CustomTabBarController: UITabBarController {

    private var customTabBarView: CustomTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupCustomTabBarView()

        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
    }

    private func setupViewControllers() {
        // Tạm thời dùng HomeVC cho tất cả các tab.
        let homeVC = HomeVC()
        homeVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "home"), tag: 0)

        let playlistVC = PlaylistVC()
        playlistVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "playlist"), tag: 1)

        let recentlyVC = RecentlyVC()
        recentlyVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "recently"), tag: 2)

        let settingVC = SettingVC()
        settingVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "setting"), tag: 3)

        viewControllers = [homeVC, playlistVC, recentlyVC, settingVC]
    }

    private func setupCustomTabBarView() {
        let items = tabBar.items ?? []
        customTabBarView = CustomTabBarView(items: items)
        customTabBarView.selectedItem = items.first // ban đầu select item đầu tiên
        customTabBarView.onTabSelected = { [weak self] index in
            self?.switchToViewController(at: index)
        }
        view.addSubview(customTabBarView)

        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.heightAnchor.constraint(equalToConstant: 75)
        ])

        customTabBarView.backgroundColor = UIColor(hex: "110E14")

        tabBar.isHidden = true
    }

    func switchToViewController(at index: Int) {
        selectedIndex = index
        customTabBarView.selectedItem = tabBar.items?[index]
    }
}
