//
//  RecordingsTableViewCell.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 13/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit
import AVKit

class RecordingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordingTitle: UILabel!
    @IBOutlet weak var recordingDuration: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var delegate: PlayAudioDelegate?
    var buttonIsSelected = false {
        didSet {
            playButton.isSelected = buttonIsSelected
            playButton.setTitle(buttonIsSelected ? "Pause" : "Play", for: buttonIsSelected ? .selected : .normal)
        }
    }
    
    var audio: Audio! {
        didSet {
            recordingTitle.text = audio.name
            recordingDuration.text = audio.duration
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setBackgroundLayer()
    }

    func setBackgroundLayer() {
        
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.colors = [Constants.cellPinkColorLeft, Constants.cellPinkColorRight]
        backgroundLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        backgroundLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        backgroundLayer.frame = CGRect(x: 0, y: 10, width: self.frame.width - 40, height: self.frame.height)
        backgroundLayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgroundLayer.cornerRadius = 8
        
        layer.insertSublayer(backgroundLayer, below: contentView.layer)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        buttonIsSelected = !buttonIsSelected
        
        if buttonIsSelected {
            delegate?.playAudio(sender: sender, cell: self)
        } else {
            delegate?.pauseAudio(sender: sender, cell: self)
        }
    }
}

protocol PlayAudioDelegate {
    func playAudio(sender: Any, cell: RecordingsTableViewCell)
    func pauseAudio(sender: Any, cell: RecordingsTableViewCell)
}
