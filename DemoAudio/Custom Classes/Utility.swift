//
//  Utillity.swift
//  DemoAudio
//
//  Created by Jonas Mock on 30.06.18.
//  Copyright © 2018 Jonas Mock. All rights reserved.
//

import Foundation
import AVFoundation


class Utility {
    
    private static func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    static func deleteAudioMemo(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    static func getFilenamesAndURLs(for folder: String) -> (success: Bool, names: [String], urls: [URL]){
        var urls = [URL]()
        var names = [String]()
        
        guard let documentDirectory = getDocumentDirectory() else {
            return (false, names, urls)
        }
        let folderDirectory = documentDirectory.appendingPathComponent(folder)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: folderDirectory, includingPropertiesForKeys: nil, options: [])
            
            for url in directoryContents {
                urls.append(url)
                let filename = url.lastPathComponent
                let cleanName = filename.replacingOccurrences(of: ".crf", with: "")
                names.append(cleanName)
            }
            return (true, names, urls)
            
        } catch {
                print("Could not search for url of fils in document directory: \(error)")
                return (false, names, urls)
            }
        }
    
    
    static func moveAudioFile(to category: String, with name: String) -> Bool {
        do {
            guard let documentDirectory = getDocumentDirectory() else { return false }
            let categoryPath = documentDirectory.appendingPathComponent(category)
            let originPath = documentDirectory.appendingPathComponent("mysound.caf")
            let destinationPath = categoryPath.appendingPathComponent(name)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            return true
            
        } catch {
            return false
        }
    }
    
    static func getAudioRecorder() -> AVAudioRecorder? {
        var audioRecorder: AVAudioRecorder?
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! audioSession.setActive(true)
                    
                    guard let documentsDirectory = getDocumentDirectory() else { return }
                    let url  = documentsDirectory.appendingPathComponent("mysound.caf")
                    
                    let settings: [String:Any] = [
                        AVFormatIDKey: Int(kAudioFormatAppleIMA4),
                        AVSampleRateKey: 44100.0,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderBitRateKey: 12800,
                        AVLinearPCMBitDepthKey: 16,
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
                    ]
                    
                    do {
                        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                    } catch {
                        print("Could not initialise Recorder")
                    }
                    
                } else {
                    print("User denied access")
                }
            }
        }
        return audioRecorder
    }
    
}
