//
//  AudioTableViewCell.swift
//  DemoAudio
//
//  Created by Jonas Mock on 30.06.18.
//  Copyright © 2018 Jonas Mock. All rights reserved.
//

import UIKit

protocol AudioCellDelegate {
    func shouldPlaySound(at url: URL)
}

class AudioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var audioFileLabel: UILabel!
    
    var url: URL?
    var delegate: AudioCellDelegate?
    
    @IBAction func playButtonHandler(_ sender: UIButton) {
        if let url = url {
           delegate?.shouldPlaySound(at: url)
        }
    }
}
