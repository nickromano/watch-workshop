//
//  ViewController.swift
//  Workshop
//
//  Created by Nick Romano on 5/10/18.
//

import UIKit
import WatchSync
import HealthKit

struct Hike {
    let startTime: Date
    let endTime: Date
    let avgHeartRate: Int
}

class ViewController: UIViewController {
    lazy var tableView = UITableView(frame: CGRect.zero, style: .grouped)

    /// Healthkit
    let healthStore = HKHealthStore()

    var token: SubscriptionToken?

    var hikes: [Hike] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])

        token = WatchSync.shared.subscribeToMessages(ofType: CompletedHikeMessage.self) { message in
            self.hikes.append(Hike(startTime: message.startTime, endTime: message.endTime, avgHeartRate: message.avgHeartRate))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hikes.append(Hike(startTime: Date(), endTime: Date(), avgHeartRate: 100))

        requestHealthkitAccessIfAvailable()
    }

    func requestHealthkitAccessIfAvailable() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
            healthStore.requestAuthorization(toShare: [], read: readDataTypes) { success, error in
                if let error = error {
                    print("Error loading healthkit \(error.localizedDescription)")
                    return
                }

                if !success {
                    print("Healthkit auth not successful")
                    return
                }

                print("Healthkit authorized!")
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hikes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let hike = hikes[indexPath.row]
        cell.textLabel?.text = "Hike! ❤️ \(hike.avgHeartRate)bmp"

        return cell
    }
}
