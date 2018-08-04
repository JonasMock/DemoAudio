//
//  AudioTableViewController.swift
//  DemoAudio
//
//  Created by Jonas Mock on 30.06.18.
//  Copyright © 2018 Jonas Mock. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewController: UIViewController {

    @IBOutlet weak var zeroHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playbarButton: UIButton!
    @IBOutlet weak var playbar: UISlider!
    
    var playerShown = false
    var audioFiles = [String]()
    var audioURLs = [URL]()
    var audioPlayer = AVAudioPlayer()
    var timer: Timer?
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if playerShown {
            audioPlayer.stop()
            stopAudio()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let documentQuery = Utility.getFilenamesAndURLs(for: tabBarItem.title!)
        if documentQuery.success {
            audioURLs = documentQuery.urls
            audioFiles = documentQuery.names
            playerShown = false
            animateplayer(show: playerShown) {
                print(self.playerShown)
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
    }
    
    func animateplayer(show: Bool, completion: @escaping () -> ()) {
        
        if show {
            zeroHeightConstraint.isActive = false
            fullHeightConstraint.isActive = true
            playerShown = true
        } else {
            fullHeightConstraint.isActive = false
            zeroHeightConstraint.isActive = true
            playerShown = false
        }
        
        UIView.animate(withDuration: 0.25, animations:  {
            self.view.layoutIfNeeded()
        }) { bool in
            completion()
        }
    }
    
    func startAudio() {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        audioPlayer.play()
    }
    
    @objc func updateSlider () {
        playbar.setValue(Float(audioPlayer.currentTime), animated: true)
    }
    
    func stopAudio() {
        timer?.invalidate()
        playerShown = !playerShown
        animateplayer(show: playerShown) {
            
        }
    }

    @IBAction func playbarHandler(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(playbar.value)
    }
    
    @IBAction func playbarButtonHandler(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            sender.setImage(UIImage(named: "PlayButton"), for: .normal)
            audioPlayer.pause()
        } else {
            sender.setImage(UIImage(named: "PauseButton"), for: .normal)
            audioPlayer.play()
        }
    }
    
}

extension AudioTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
    }
}

extension AudioTableViewController: AudioCellDelegate {
    
    func shouldPlaySound(at url: URL) {
        playbarButton.setImage(UIImage(named: "PauseButton"), for: .normal)
        playbar.setValue(0.0, animated: false)
        if !playerShown {
            //Animate Player
            playerShown = !playerShown
            animateplayer(show: playerShown) {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer.delegate = self
                    self.playbar.maximumValue = Float(self.audioPlayer.duration)
                    self.startAudio()
                } catch {
                    print(error)
                }
            }
        } else {
            //Play Audio
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                playbar.maximumValue = Float(audioPlayer.duration)
                print("shown")
                startAudio()
            } catch {
                print(error)
            }
        }
    }
    
}

extension AudioTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioTableViewCell
        cell.audioFileLabel.text = audioFiles[indexPath.row]
        cell.url = audioURLs[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let cell = tableView.cellForRow(at: indexPath) as?
                AudioTableViewCell{
                if Utility.deleteAudioMemo(at: cell.url!) {
                    audioURLs.remove(at: indexPath.row)
                    audioFiles.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
        }
    }
}
