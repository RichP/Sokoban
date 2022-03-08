//
//  GameCell.swift
//  sokoban
//
//  Created by Richard Pickup on 31/08/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import Foundation
import UIKit


class GameCell : UICollectionViewCell {
    
   
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var padlock: UIImageView!
    
    
    @IBOutlet weak var numMoves: UILabel!
    
    
    
    
    @IBOutlet weak var numPushes: UILabel!
    
}
