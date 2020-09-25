//
//  PlayAudioDelegate.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 25/09/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import Foundation

protocol PlayAudioDelegate {
    func playAudio(sender: Any, cell: RecordingsTableViewCell)
    func pauseAudio(sender: Any, cell: RecordingsTableViewCell)
}
