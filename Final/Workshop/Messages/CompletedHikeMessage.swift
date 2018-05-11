//
//  CompletedHikeMessage.swift
//  Workshop
//
//  Created by Nick Romano on 5/10/18.
//

import Foundation
import WatchSync

struct CompletedHikeMessage: SyncableMessage {
    let startTime: Date
    let endTime: Date
    let avgHeartRate: Int
}
