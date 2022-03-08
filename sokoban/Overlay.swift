//
//  Overlay.swift
//  sokoban
//
//  Created by Richard Pickup on 25/06/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

protocol OverlayTouchDelegate {
    func didUndo()
}

class Overlay : SKScene {
    
    var touchDelegate:OverlayTouchDelegate?
    
    var movesLabel:SKLabelNode
    var pushesLabel:SKLabelNode
    
    var boxesOnGoal:SKLabelNode
    
    var undoButton:SKSpriteNode
    
    override init(size: CGSize) {
        movesLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        pushesLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        boxesOnGoal = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        undoButton = SKSpriteNode(imageNamed: "undo-3")
        super.init(size: size)
        
        let iPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        var scale = iPad == true ? 1.5 : 1.0
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = SKSceneScaleMode.aspectFill
        
        
        
        movesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        movesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        movesLabel.text = " "
        movesLabel.fontColor = SKColor.black
        movesLabel.fontSize = 15
        
        var af = movesLabel .calculateAccumulatedFrame()
        movesLabel.position = CGPoint(x: -(size.width) / 2, y: (size.height - af.size.height) / 2 - 20)
        self.addChild(movesLabel)
        
        pushesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        pushesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        pushesLabel.text = " "
        pushesLabel.fontColor = SKColor.black
        pushesLabel.fontSize = 15
        
        af = pushesLabel .calculateAccumulatedFrame()
        pushesLabel.position = CGPoint(x: 0, y: (size.height - af.size.height) / 2 - 20)
        
        
        self.addChild(pushesLabel)
        
        boxesOnGoal.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        boxesOnGoal.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        boxesOnGoal.text = " "
        boxesOnGoal.fontColor = SKColor.black
        boxesOnGoal.fontSize = 15
        
        af = boxesOnGoal .calculateAccumulatedFrame()
        boxesOnGoal.position = CGPoint(x: -(size.width) / 2, y: (size.height - af.size.height) / 2 - 40)
        
        
        self.addChild(boxesOnGoal)

        
        undoButton.xScale = 0.1
        undoButton.yScale = 0.1
        undoButton.position = CGPoint(x: (size.width) / 2  - undoButton.size.width, y: -(size.height) / 2 + undoButton.size.height)
        undoButton.name = "UndoButton"
        self.addChild(undoButton)
  
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showCongrats() {
        var congratsLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        
        congratsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        congratsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        congratsLabel.text = "Congratulations"
        congratsLabel.fontColor = SKColor.black
        congratsLabel.fontSize = 15
        
        congratsLabel.position = CGPoint(x: -320, y: 0)
        
        self.addChild(congratsLabel)
        
        let action = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.5)
        
        congratsLabel.run(action)
        
    }
    
 

    
    func setMoves(moves: Int) {
        movesLabel.text = " : \(moves)"
    }
    
    func setPushes(pushes:Int) {
        pushesLabel.text = " : \(pushes)"
    }
    
    func setBoxesStored(stored:Int) {
        boxesOnGoal.text = " : \(stored)"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let node = self.atPoint(point)
        
        if(node == self.undoButton) {
            touchDelegate?.didUndo()
        }
    }

};
