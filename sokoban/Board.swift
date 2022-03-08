//
//  Board.swift
//  sokoban
//
//  Created by Richard Pickup on 22/06/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import Foundation




/*

Sokoban levels are usually stored as a character array where

space is an empty square
# is a wall
@ is the player
$ is a box
. is a goal
+ is the player on a goal
* is a box on a goal
*/


class Board {
    
    
    var numMoves = 0
    var numPushes = 0
    
    let EMPTY = -1
    let WALL = 1
    let SPACE = 0
    let BOX = 2
    let PLAYER = 3
    let GOAL = 4
    let PLAYER_ON_GOAL = 5
    let BOX_ON_GOAL = 6
    
    var numBoxes = 0
    var numGoals = 0
   
    var board = Array<Int>()
    
    var width = 0
    var height = 0
    
    var moves = Array<Dictionary<String, Int>>()
    
    
    var boxesOnGoals : Int = 0 {
        didSet {
            print("Old value is \(oldValue), new value is \(boxesOnGoals)")
            
            if boxesOnGoals >=  numGoals{
                print("level complete")
            }
        }
    }
    
    var levelComplete : Bool {
        return boxesOnGoals >=  numGoals
    }
    
    init() {
        
    }
    
    func loadMap(levelNum: Int) {
        self.board = []
        self.moves = []
        
        self.numBoxes = 0
        self.numGoals = 0
        self.width = 0
        self.height = 0
        self.numMoves = 0
        self.numPushes = 0
        self.boxesOnGoals = 0
        

        guard let path = Bundle.main.path(forResource: "boards", ofType:"plist"),
              let array = NSArray(contentsOfFile:path) else { return }
        
        
        var dict: NSDictionary
        if array.count > levelNum {
            dict = array[levelNum] as! NSDictionary
        }
        else {
            dict = array[0] as! NSDictionary
        }
        
        let nsDict = dict as NSDictionary
        let width = nsDict.object(forKey: "width") as! NSNumber
        let height = nsDict.object(forKey: "height") as! NSNumber
        let maplines = nsDict.object(forKey: "maplines") as! NSArray
        
        
        maplines.forEach { string in
            let nsString = string as! NSString
            
            for character in nsString as String {
                print(character)
                switch character {
                case " ":
                    board.append(SPACE)
                case "#":
                    board.append(WALL)
                case "=":
                    board.append(SPACE)
                case "$":
                    board.append(BOX);
                    numBoxes += 1
                case "@":
                    board.append(PLAYER)
                case ".":
                    board.append(GOAL)
                    numGoals += 1
                default:break
                }
            }
        }
        
        self.width = width.intValue
        self.height = height.intValue
    }
    
    func canMoveTo(x: Int, y:Int) ->Bool {
        let piece = pieceAt(x: x, y:y)
        if pieceAt(x: x, y:y) == GOAL || pieceAt(x: x, y:y) ==  SPACE {
            return true
        }
        
        return false
    }
    
    func boxAt(x: Int, y:Int) ->Bool {
        let piece = pieceAt(x: x, y:y)
        if pieceAt(x: x, y:y) == BOX  || pieceAt(x: x, y:y) == BOX_ON_GOAL {
            return true
        }
        return false
    }
    
    func pieceAt(x: Int, y:Int) ->Int {
        return board[y * width + x]
    }
    
    func storeMove(x:Int, y:Int, nX:Int, nY:Int) {
        let moveDict = [
            "x": x,
            "y": y,
            "nX": nX,
            "nY": nY,
        ]
        
        moves.append(moveDict)
    }
    
    func movePiece(x:Int, y:Int, nX:Int, nY:Int) {
        
        let pieceA = pieceAt(x: x, y:y)
        let pieceB = pieceAt(x: nX, y:nY)
        
        if pieceA == PLAYER ||  pieceA == PLAYER_ON_GOAL{
            numMoves += 1
        }
        
        if pieceA == BOX ||  pieceA == BOX_ON_GOAL {
            numPushes += 1
        }
        
        if pieceB == GOAL {
            if pieceA == PLAYER {
                board[y * width + x] = SPACE
                board[nY * width + nX] = PLAYER_ON_GOAL
            }
            if pieceA == PLAYER_ON_GOAL {
                board[y * width + x] = GOAL
                board[nY * width + nX] = PLAYER_ON_GOAL
            }
            
            if pieceA == BOX {
                board[y * width + x] = SPACE
                board[nY * width + nX] = BOX_ON_GOAL
                boxesOnGoals += 1
            }
            
            if pieceA == BOX_ON_GOAL {
                board[y * width + x] = GOAL
                board[nY * width + nX] = BOX_ON_GOAL
            }
        }
        
        if pieceB == SPACE {
            if pieceA == PLAYER {
                board[y * width + x] = SPACE
                board[nY * width + nX] = PLAYER
            }
            if pieceA == PLAYER_ON_GOAL {
                board[y * width + x] = GOAL
                board[nY * width + nX] = PLAYER
            }
            
            if pieceA == BOX {
                board[y * width + x] = SPACE
                board[nY * width + nX] = BOX
            }
            if pieceA == BOX_ON_GOAL {
                boxesOnGoals -= 1
                board[y * width + x] = GOAL
                board[nY * width + nX] = BOX
            }

        }
    }
}
