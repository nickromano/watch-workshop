//
//  HikeStatsController.swift
//  Workshop WatchKit Extension
//
//  Created by Nick Romano on 5/10/18.
//

import Foundation
import WatchKit
import WatchSync
import HealthKit

class HikeStatsController: WKInterfaceController {
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer! {
        didSet {
            timer.start()
        }
    }

    /// Healthkit
    static let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    let healthStore = HKHealthStore()
    var anchor: HKQueryAnchor?
    var observerHeartRateQuery: HKQuery?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        WatchSync.shared.update(applicationContext: ["onHike": true], completion: nil)

        if HKHealthStore.isHealthDataAvailable() {
            let predicate = HKQuery.predicateForSamples(withStart: Date(timeIntervalSinceNow: 60 * 60), end: nil, options: [])

            observerHeartRateQuery = HKObserverQuery(sampleType: HikeStatsController.heartRateSampleType, predicate: predicate) { [weak self] _, completion, error in
                if let error = error {
                    print("Error pull heart rates \(error.localizedDescription)")
                    return
                }

                self?.fetchLatestHeartRate(predicate: predicate) { heartRate in
                    if let heartRate = heartRate {
                        self?.heartRateLabel.setText("❤️ \(heartRate)bpm")
                    } else {
                        self?.heartRateLabel.setText("❤️ ~")
                    }
                }
            }
            healthStore.execute(observerHeartRateQuery!)
        } else {
            print("Healthkit not available")
        }
    }

    deinit {
        if let observerHeartRateQuery = observerHeartRateQuery {
            healthStore.stop(observerHeartRateQuery)
        }
    }

    func fetchLatestHeartRate(predicate: NSPredicate, completion: @escaping (Double?) -> Void) {
        let query = HKAnchoredObjectQuery(type: HikeStatsController.heartRateSampleType, predicate: predicate, anchor: anchor, limit: 1000) { _, samples, _, anchor, error in
            if let error = error {
                print("Error pulling heart rates \(error.localizedDescription)")
                return
            }

            self.anchor = anchor

            guard let sample = samples?.last as? HKQuantitySample else {
                return
            }
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate)
        }
        healthStore.execute(query)
    }

    @IBAction func endHikeButtonPressed() {
        WatchSync.shared.update(applicationContext: ["onHike": false], completion: nil)

        let message = CompletedHikeMessage(startTime: Date(), endTime: Date(), avgHeartRate: 0)
        WatchSync.shared.sendMessage(message) { result in
            switch result {
            case .failure(_):
                break
            case .sent:
                break
            case .delivered:
                break
            }
        }

        WKInterfaceController.reloadRootPageControllers(withNames: [String(describing: StartHikeController.self)], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
}
