//
//  RecVC+PlayAudio.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 14/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import AVFoundation
import UIKit

extension RecordingsViewController: PlayAudioDelegate, AVAudioPlayerDelegate {
    func preparePlayer(urlName: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL(filename: urlName))
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
        } catch {
            if let err = error as Error? {
                print("AudioPlayer error: \(err.localizedDescription)")
                audioPlayer = nil
            }
        }
    }

    func playAudio(sender: Any, cell: RecordingsTableViewCell) {
        guard let cell = (sender as AnyObject).superview?.superview as? RecordingsTableViewCell else {
            return
        }

        if let oldIndexPath = playingIndexPath, let oldCell = recordingsList.cellForRow(at: oldIndexPath) as? RecordingsTableViewCell {
            oldCell.buttonIsSelected = false
        }

        let indexPath = recordingsList.indexPath(for: cell)

        playingIndexPath = indexPath
        let urlName = storedAudios[indexPath?.row ?? 0].storedName
        preparePlayer(urlName: urlName)
        audioPlayer.play()
    }

    func pauseAudio(sender: Any, cell: RecordingsTableViewCell) {
        audioPlayer?.pause()
        cell.buttonIsSelected = false
        playingIndexPath = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let playingIndexPath = playingIndexPath else { return }
        guard let cell = recordingsList.cellForRow(at: playingIndexPath) as? RecordingsTableViewCell else { return }
        guard let playButton = cell.playButton else { return }
        pauseAudio(sender: playButton, cell: cell)
    }
}
