//
//  StartHikeController.swift
//  Workshop WatchKit Extension
//
//  Created by Nick Romano on 5/10/18.
//

import Foundation
import WatchKit

class StartHikeController: WKInterfaceController {
    @IBAction func startHikeButtonPressed() {
        WKInterfaceController.reloadRootPageControllers(
            withNames: [
                String(describing: HikeStatsController.self),
                String(describing: HikeMapController.self)
            ],
            contexts: nil,
            orientation: .horizontal,
            pageIndex: 0
        )
    }
}
