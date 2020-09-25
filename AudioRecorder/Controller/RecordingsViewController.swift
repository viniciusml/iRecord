//
//  RecordingsViewController.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 13/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import AVFoundation
import UIKit

class RecordingsViewController: UIViewController {
    let defaults = UserDefaults.standard
    var storedAudios = [Audio]()
    var playingIndexPath: IndexPath?
    var audioPlayer: AVAudioPlayer!

    @IBOutlet weak var recordingsList: UITableView!

    @objc func didTapDismiss() {
        dismiss(animated: true, completion: nil)
        if let audioplr = audioPlayer {
            audioplr.stop()
        }
    }

    func loadData() {
        guard let retrievedData = defaults.object(forKey: "SavedArray") as? NSData else {
            print("'storedAudios' not found in UserDefaults")
            return
        }

        guard let retrievedArray = NSKeyedUnarchiver.unarchiveObject(with: retrievedData as Data) as? [Audio]
        else {
            print("Could not unarchive from retrievedData")
            return
        }
        storedAudios = retrievedArray
    }

    func setupDismissButton() {
        let dismissButton = UIButton(type: .custom)
        let image = UIImage(named: "dismiss")
        image?.withRenderingMode(.alwaysTemplate)
        dismissButton.setImage(image, for: .normal)
        dismissButton.tintColor = Constants.pinkColor
        dismissButton.frame.size = CGSize(width: 40, height: 40)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)

        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func setupBackgroundLayer() {
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor.white.cgColor
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backgroundLayer.shadowColor = Constants.pinkGradientTop
        backgroundLayer.shadowOffset = .zero
        backgroundLayer.shadowRadius = 18
        backgroundLayer.shadowOpacity = 1
        backgroundLayer.cornerRadius = 120
        backgroundLayer.masksToBounds = false
        backgroundLayer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        view.layer.insertSublayer(backgroundLayer, below: recordingsList.layer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingsList.rowHeight = 120

        // This is to push main TV down.
        recordingsList?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        recordingsList?.showsVerticalScrollIndicator = false

        setupDismissButton()
        setupBackgroundLayer()
        recordingsList.delegate = self
        loadData()
    }
}
