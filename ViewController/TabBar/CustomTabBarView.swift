//
//  CustomTabBarView.swift
//  TUANNM_MV_2509
//
//  Created by Phạm Quý Thịnh on 7/1/25.
//

import UIKit
import Foundation

class CustomTabBarView: UIView {

    var items: [UITabBarItem] = []
    var selectedItem: UITabBarItem? {
        didSet {
            guard let item = selectedItem else { return }
            for button in buttons {
                button.isSelected = (button.tag == item.tag)
                updateButtonAppearance(button)
            }
            animateIndicator(to: item.tag)
        }
    }

    var onTabSelected: ((Int) -> Void)?

    private var buttons: [UIButton] = []

    private let selectedImages: [UIImage?] = [
        UIImage(named: "home"), UIImage(named: "playlist"),
        UIImage(named: "recently"), UIImage(named: "setting")
    ]
    private let unselectedImages: [UIImage?] = [
        UIImage(named: "home_in"), UIImage(named: "playlist_in"),
        UIImage(named: "recently_in"), UIImage(named: "setting_in")
    ]

    private let indicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "61BFE7")
        view.layer.cornerRadius = 1.5
        return view
    }()

    init(items: [UITabBarItem]) {
        self.items = items
        super.init(frame: .zero)
        setupView()
        setupIndicator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        for (index, _) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.setImage(unselectedImages[index] ?? UIImage(), for: .normal)
            button.setTitle(items[index].title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(UIColor(hex: "#ED802D"), for: .selected)
            button.tag = index
            // button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            button.imageEdgeInsets = .zero
            button.titleEdgeInsets = .zero
            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)

            buttons.append(button)
            addSubview(button)
        }

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupIndicator() {
        addSubview(indicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if buttons.count > 0 {
            let buttonWidth = self.bounds.width / CGFloat(buttons.count)
            let indicatorHeight: CGFloat = 3.0
            let yPosition: CGFloat = 0
            let index = selectedItem?.tag ?? 0
            let xPosition = CGFloat(index) * buttonWidth
            indicator.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: indicatorHeight)
        }
    }

    private func animateIndicator(to index: Int) {
        guard buttons.count > 0 else { return }
        let buttonWidth = self.bounds.width / CGFloat(buttons.count)
        let targetX = CGFloat(index) * buttonWidth
        UIView.animate(withDuration: 0.3) {
            self.indicator.frame.origin.x = targetX
        }
    }

    private func updateButtonAppearance(_ button: UIButton) {
        let index = button.tag
        if button.isSelected {
            button.setImage(selectedImages[index] ?? UIImage(), for: .selected)
        } else {
            button.setImage(unselectedImages[index] ?? UIImage(), for: .normal)
        }
    }

    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let selectedItem = items[index]
        self.selectedItem = selectedItem
        onTabSelected?(index)
    }
}
