//
//  AudioPlayerService.swift
//  Goose
//
//  Created by Sahil Chaddha on 2024-03-22.
//

import Foundation
import AVFoundation


class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()
    
    var audioPlayer: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer?.play()
            Logger.log("AudioPlayerService: Goose honk played")
        } catch let error {
            Logger.log("AudioPlayerService: ERROR \(error)")
        }
    }
}
