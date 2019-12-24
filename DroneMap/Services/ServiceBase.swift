//
//  ServiceBase.swift
//  DroneMap
//
//  Created by Evgeny Agamirzov on 4/20/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import DJISDK

class ServiceBase {
    typealias KeyActionMap = [DJIKey?:(_ oldValue: DJIKeyedValue?, _ newValue: DJIKeyedValue?) -> Void]

    var env: Environment
    var keyActionMap: KeyActionMap = [:]
    
    init(_ env: Environment) {
        self.env = env
        env.connectionService().addDelegate(self)
    }
    
    // Since actions are in fact member functions of the child class this map
    // cannot be set via the initializer and instead a setter is used.
    func setKeyActionMap(_ keyActionMap: KeyActionMap) {
        self.keyActionMap = keyActionMap
    }
}

/*************************************************************************************************/
extension ServiceBase : ServiceProtocol {
    func start() {
        for keyActionPair in keyActionMap {
            guard let key = keyActionPair.key else { continue }
            DJISDKManager.keyManager()?.getValueFor(key, withCompletion: {
                (value: DJIKeyedValue?, error: Error?) in
                guard error == nil else {
                    return
                }
                keyActionPair.value(nil, value)
            })
            DJISDKManager.keyManager()?.startListeningForChanges(on: key, withListener: self, andUpdate: {
                (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                keyActionPair.value(oldValue, newValue)
            })
        }
    }
    
    func stop() {
        for keyActionPair in keyActionMap {
            guard let key = keyActionPair.key else { continue }
            DJISDKManager.keyManager()?.stopListening(on: key, ofListener: self)
        }
    }
}

/*************************************************************************************************/
extension ServiceBase : ConnectionServiceDelegate {
    func statusChanged(_ status: ConnectionStatus) {
        if status == .connected {
            self.start()
        } else {
            self.stop()
        }
    }
}
