//
//  SoundManager.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 05/04/24.
//
import AVFoundation

class SoundManager {
    
    private var soundDict: [Sound:AVAudioPlayer?] = [:]
    
    init() {
        for sound in Sound.allCases {
            soundDict[sound] = getAudioPlayer(sound: sound)
        }
    }
    
    private func getAudioPlayer(sound: Sound) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: ".mp3"
        ) else {
            print("Fail to get url for \(sound)")
            return nil
        }

        var audioPlayer: AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            return audioPlayer
        } catch {
            print("Fail to load \(sound)")
            return nil
        }
    }
    
    func playLoop(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    func fadeOut(sound: Sound){
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        
        if audioPlayer.volume != 0.0{
            audioPlayer.volume -= 0.1
        }else{
            audioPlayer.pause()
            return
        }
    }
    
    func play(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.play()
    }
    
    func pause(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.pause()
    }
    
    func stop(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.currentTime = 0
        audioPlayer.pause()
    }
    
    enum Sound: String, CaseIterable {
        case theme
    }
}
