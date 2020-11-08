//
//  MissionViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 4/6/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class MissionViewController : UIViewController {
    private var missionView: MissionView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        missionView = MissionView()
        registerListeners()
        view = missionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// Private methods
extension MissionViewController {
    private func registerListeners() {
        missionView.cancelButtonPressed = {
            Environment.missionStateManager.state = .none
        }
        Environment.commandService.commandResponseListeners.append({ id, success in
            if success && id == .upload {
                Environment.missionStateManager.state = .uploaded
            }
        })
        Environment.missionStateManager.stateListeners.append({ newState in
            if newState == .editing {
                self.toggleShowFromSideAnimated(show: true, delay: Animations.defaultDelay)
            } else {
                self.toggleShowFromSideAnimated(show: false, delay: 0)
            }
        })
        Environment.connectionService.listeners.append({ model in
            if model != nil && Environment.missionStorage.activeMissionPresent() {
                // Set state based on DJI execution state
            }
        })
    }

    private func toggleShowFromSideAnimated(show: Bool, delay: TimeInterval) {
        UIView.animate(
            withDuration: Animations.defaultDuration,
            delay: delay,
            options: [],
            animations: {
                self.missionView.toggleShowFromSide(show)
            }
        )
    }
}
