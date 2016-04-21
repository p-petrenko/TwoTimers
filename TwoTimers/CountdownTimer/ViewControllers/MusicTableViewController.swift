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
    
    var selectedRow : Int?
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    //    audio
    var audioData : NSData?
    var audioPlayer : AVAudioPlayer?
    
    var arrayOfFormatsForFileNames = [String]()
    
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(Constants.arrayOfFileNames[0], ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("An error occured , trying to take data from \(audioData) ,\(error.localizedDescription)")
        }
        
        audioPlayer!.prepareToPlay()
        
        if let selectedRowIndex = defaults.objectForKey(Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            selectedRow = selectedRowIndex
        } else {
            selectedRow = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        defaults.setObject(selectedRow, forKey: Constants.DefaultKeys.AudioKeyForChosenMelody)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.arrayOfFancyMelodyNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Music Cell", forIndexPath: indexPath) as! MusicTableViewCell
        
        cell.melodyName.text = Constants.arrayOfFancyMelodyNames[indexPath.row]
        let image = UIImage(named: "Checkmark")
        if indexPath.row == selectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            cell.chosenMelodyImage.image = image
        } else {
            cell.chosenMelodyImage.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if audioPlayer != nil && audioPlayer!.playing {
            audioPlayer!.stop()
        }
        
        selectedRow = indexPath.row
        tableView.reloadData()
        
        audioData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(Constants.arrayOfFileNames[selectedRow!], ofType: "mp3")!)
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("Error trying to get URL of the melody, \(error.description)")
        }
        audioPlayer!.play()
        return indexPath
    }
}
