//
//  MusicTableViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 05.04.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import AVFoundation

class MusicTableViewController: UITableViewController {
    
    var selectedRow: Int?
    var defaults = UserDefaults.standard
    
    //    audio
    var audioData: Data?
    var audioPlayer: AVAudioPlayer?
    
    var arrayOfFormatsForFileNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: Constants.arrayOfFileNames[0], ofType: "mp3")!))
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("An error occured , trying to take data from \(audioData) ,\(error.localizedDescription)")
        }
        
        audioPlayer!.prepareToPlay()
        
        if let selectedRowIndex = defaults.value(forKey: Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            selectedRow = selectedRowIndex
        } else {
            selectedRow = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaults.setValue(selectedRow, forKey: Constants.DefaultKeys.AudioKeyForChosenMelody)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.arrayOfFancyMelodyNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Music Cell", for: indexPath) as! MusicTableViewCell
        
        cell.melodyName.text = Constants.arrayOfFancyMelodyNames[indexPath.row]
        let image = UIImage(named: "Checkmark")
        if indexPath.row == selectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            cell.chosenMelodyImage.image = image
        } else {
            cell.chosenMelodyImage.image = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if audioPlayer != nil && audioPlayer!.isPlaying {
            audioPlayer!.stop()
        }
        
        selectedRow = indexPath.row
        tableView.reloadData()
        
        audioData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: Constants.arrayOfFileNames[selectedRow!], ofType: "mp3")!))
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("Error trying to get URL of the melody, \(error.description)")
        }
        audioPlayer!.play()
        return indexPath
    }
}
