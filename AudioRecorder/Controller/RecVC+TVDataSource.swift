//
//  RecVC+TVDataSource.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 14/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit

extension RecordingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storedAudios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordingsTableViewCell

        cell.delegate = self

        let audio = storedAudios[indexPath.row]
        cell.audio = audio

        if let currentIndexPath = playingIndexPath, indexPath == currentIndexPath {
            cell.buttonIsSelected = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storedAudios.remove(at: indexPath.row)
            tableView.reloadData()
        }

        do {
            let myData = try NSKeyedArchiver.archivedData(withRootObject: storedAudios, requiringSecureCoding: false)
            defaults.set(myData, forKey: "SavedArray")
        } catch {
            print("error during archive")
        }
    }
}
