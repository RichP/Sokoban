//
//  GameSelectViewController.swift
//  sokoban
//
//  Created by Richard Pickup on 31/08/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import Foundation
import UIKit


class GameSelectViewController: UICollectionViewController {
    
    var completedLevels:NSNumber = 0
    
    var levelsDict:[String :Dictionary<String,String>] = [:]
    
    
    
    @IBAction func unwindToGameSelect(segue: UIStoryboardSegue) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundView = UIImageView(image: UIImage(named: "background"))
        
        let layout:UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.sectionInset = UIEdgeInsets(top: 60, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 50;
        
        //   let curLev = NSNumber(int: 0)
        //   NSUserDefaults.standardUserDefaults().setObject(curLev, forKey: "completedLevels")
        //   NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let savedNumber: NSNumber? = UserDefaults.standard.object(forKey: "completedLevels") as? NSNumber
        
        if ( (savedNumber) != nil ) {
            
            
            self.completedLevels = savedNumber ?? 0
            
            print("\(self.completedLevels.intValue)")
            
            let levelsDict: AnyObject! = UserDefaults.standard.dictionary(forKey: "levelScores") as AnyObject
            
            if ( (levelsDict) != nil ) {
                
                
                self.levelsDict = levelsDict as! Dictionary<String, Dictionary<String,String>>
                
                print("\(String(describing: levelsDict))")
                
            }
            
            
            self.collectionView.reloadData()
            
        }   
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GameCell
        
        
        cell.title.text = "\(indexPath.row + 1)"
        
        cell.numMoves.text = "0"
        
        cell.numPushes.text = "0"
        
        
        
        
        let bgImage = UIImageView(frame: cell.contentView.bounds)
        bgImage.image = UIImage(named: "square-button-off")
        cell.backgroundView = bgImage;
        
        
        if(indexPath.row >  self.completedLevels.intValue) {
            cell.padlock.isHidden = false
            
            cell.title.isHidden = true
            
            cell.numMoves.isHidden = true
            
            cell.numPushes.isHidden = true
        }
        else {
            cell.padlock.isHidden = true
            
            cell.title.isHidden = false
            
            cell.numMoves.isHidden = false
            
            cell.numPushes.isHidden = false
            
            let dict = self.levelsDict["level\(indexPath.row)"]
            
            if( (dict) != nil) {
                let moves = dict!["MOVES"]
                
                let pushes = dict!["PUSHES"]
                
                cell.numMoves.text = moves
                cell.numPushes.text = pushes
            }
        }
        
        
        
        return cell as GameCell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let indexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)
        
        if(indexPath!.row >  self.completedLevels.intValue) {
            
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGameView" {
            
            let destViewController = segue.destination as! GameViewController
            let indexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)
            
            
            destViewController.currentLevel = indexPath!.row
            
        }
    }
    
}
