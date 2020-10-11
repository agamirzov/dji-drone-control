//
//  StatusView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 04.10.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class StatusView : UIView {
    // Stored properties
    private let menuButton = MenuButton()
    private let stackView = UIStackView()
    private let simulatorButton = SimulatorButton()

    // Notifyer properties
    var menuButtonSelected: ((_ isSelected: Bool) -> Void)?
    var simulatorButtonSelected: ((_ isSelected: Bool) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect(
            x: 0,
            y: 0,
            width: Dimensions.screenWidth,
            height: Dimensions.tileSize
        ))

        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center

        menuButton.addTarget(self, action: #selector(onMenuButtonPressed(_:)), for: .touchUpInside)
        menuButton.isSelected = false
        simulatorButton.addTarget(self, action: #selector(onSimulatorButtonPressed(_:)), for: .touchUpInside)
        simulatorButton.isSelected = false

        stackView.addArrangedSubview(menuButton)
        stackView.addArrangedSubview(Environment.consoleViewController.view)
        stackView.addArrangedSubview(Environment.staticTelemetryViewController.view)
        stackView.addArrangedSubview(simulatorButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false;
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// Public methods
extension StatusView {
    func triggerMenuButtonSelection(_ select: Bool) {
        menuButton.isSelected = select
    }

    func triggerSimulatorButtonSelection(_ select: Bool) {
        simulatorButton.isSelected = select
    }
}

// Handle control events
extension StatusView {
    @objc func onMenuButtonPressed(_: LocatorButton) {
        menuButtonSelected?(!menuButton.isSelected)
    }

    @objc func onSimulatorButtonPressed(_: SimulatorButton) {
        simulatorButtonSelected?(!simulatorButton.isSelected)
    }
}