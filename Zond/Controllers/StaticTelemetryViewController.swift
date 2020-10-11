//
//  StaticTelemetryViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 23.05.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class StaticTelemetryViewController : UIViewController {
    private var staticTelemetryView: StaticTelemetryView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        staticTelemetryView = StaticTelemetryView()
        registerListeners()
        view = staticTelemetryView
    }
}

// Private methods
extension StaticTelemetryViewController {
    private func registerListeners() {
        Environment.telemetryService.telemetryDataChanged = { id, value in
            self.staticTelemetryView.updateData(id, value)
        }
    }
}