//
//  MainMenuViewController.swift
//  sokoban
//
//  Created by Richard Pickup on 31/08/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import Foundation
import UIKit


class MainMenuViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if 0 == section {
            return 120
        }
        
        return 10
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bgImage = UIImageView(frame: cell.contentView.bounds)
        bgImage.image = UIImage(named: "wide-button-on")
        cell.backgroundView = bgImage;
    }
}
