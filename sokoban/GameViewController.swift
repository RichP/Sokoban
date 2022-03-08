//
//  GameViewController.swift
//  sokoban
//
//  Created by Richard Pickup on 22/06/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit



class GameViewController: UIViewController, OverlayTouchDelegate {
    var currentLevel = 2
    let newBoard = Board()
    
    let scene = SCNScene()
    
    let sphereNode = SCNNode()
    
    let camNode = SCNNode()
    
    var mapRoot = SCNNode()
    
    var isMoving = false
    
    
    var gameOver = false
    
    
    @IBOutlet var pushesLabel: UILabel!
    @IBOutlet var gameOverView: UIImageView!
    @IBOutlet var levelFinishedHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var movesLabel: UILabel!
    @IBOutlet var storedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create a new scene
        
        
        // create and add a camera to the scene
        camNode.camera = SCNCamera()
        scene.rootNode.addChildNode(camNode)
        camNode.position = SCNVector3(x: 0, y: 15, z: 5)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        
        
        let floorNode = SCNNode()
        let floor = SCNFloor()
        floor.reflectivity = 0.5
        floorNode.geometry = floor
        scene.rootNode.addChildNode(floorNode)
        
        // create and configure a material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "herringbone")
        material.specular.contents = UIColor.gray
        material.locksAmbientWithDiffuse = true
        material.diffuse.mipFilter = SCNFilterMode.linear
        
        floorNode.geometry!.firstMaterial = material
        floorNode.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 1)
        floorNode.geometry!.firstMaterial!.diffuse.wrapS = SCNWrapMode.repeat
        floorNode.geometry!.firstMaterial!.diffuse.wrapT = .repeat
        
        resetBoard();
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        
        let gestureRecognizers = NSMutableArray()
        
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gestureRecognize:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gestureRecognize:)))
        leftSwipeGesture.direction = .left
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gestureRecognize:)))
        upSwipeGesture.direction = .up
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gestureRecognize:)))
        downSwipeGesture.direction = .down
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(recognizer:)))
        
        gestureRecognizers.add(rightSwipeGesture)
        gestureRecognizers.add(leftSwipeGesture)
        gestureRecognizers.add(upSwipeGesture)
        gestureRecognizers.add(downSwipeGesture)
        gestureRecognizers.add(pinchGesture)
        
        scnView.gestureRecognizers = gestureRecognizers as? [UIGestureRecognizer]
        
        pushesLabel.text = "0"
        movesLabel.text = "0"
        storedLabel.text = "0"
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameOverView.image = UIImage(named: "square-button-off")
        self.gameOverView.isHidden = true;
        _ = self.levelFinishedHorizontalConstraint.constant
        self.levelFinishedHorizontalConstraint.constant = -(self.view.bounds.width + 16)
    }
    
    func resetBoard() {
        mapRoot.removeFromParentNode();
        
        mapRoot = SCNNode()
        
        newBoard.loadMap(levelNum: currentLevel)
        
        let material2 = SCNMaterial()
        material2.diffuse.contents = UIImage(named: "Brick")
        material2.specular.contents = UIColor.gray
        material2.locksAmbientWithDiffuse = true
        material2.diffuse.mipFilter = SCNFilterMode.linear
        
        let crate = SCNMaterial()
        crate.diffuse.contents = UIImage(named: "Crate")
        crate.specular.contents = UIColor.gray
        crate.locksAmbientWithDiffuse = true
        crate.diffuse.mipFilter = SCNFilterMode.linear
        
        let plate = SCNMaterial()
        plate.diffuse.contents = UIImage(named: "plate")
        plate.specular.contents = UIColor.white
        plate.locksAmbientWithDiffuse = true
        plate.diffuse.mipFilter = SCNFilterMode.linear
        
        
        let goalTex = SCNMaterial()
        goalTex.diffuse.contents = UIImage(named: "goal")
        goalTex.specular.contents = UIColor.white
        goalTex.locksAmbientWithDiffuse = true
        goalTex.diffuse.mipFilter = SCNFilterMode.linear
        
        
        let bWidth = newBoard.width
        let bHeight = newBoard.height
        
        var wallFlat = SCNNode()
        
        for y in 0..<bHeight {
            let pZ:Int = y - (bHeight / 2)
            for x in 0..<bWidth {
                let piece = newBoard.pieceAt(x: x, y:y)
                let pX:Int = x - (bWidth / 2)
                print("piece \(piece)")
                switch piece {
                case 1:
                    let boxNode3 = SCNNode()
                    boxNode3.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    boxNode3.position = SCNVector3Make(CFloat(pX), 0.5, CFloat(pZ))
                    wallFlat.addChildNode(boxNode3)
                    boxNode3.geometry!.firstMaterial = material2
                case 2:
                    let boxNode3 = SCNNode()
                    boxNode3.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    boxNode3.position = SCNVector3Make(CFloat(pX), 0.5, CFloat(pZ))
                    mapRoot.addChildNode(boxNode3)
                    boxNode3.geometry!.firstMaterial = crate
                    boxNode3.name = "\(y * bWidth + x)"
                case 3:
                    let sphere = SCNSphere(radius: 0.5)
                    sphere.segmentCount = 8
                    sphereNode.position = SCNVector3Make(CFloat(pX), 0.5, CFloat(pZ))
                    sphereNode.geometry = sphere
                    mapRoot.addChildNode(sphereNode)
                    sphereNode.geometry!.firstMaterial = plate
                    
                    camNode.position = SCNVector3(x: CFloat(pX), y: 15, z: CFloat(pZ) + 5)
                    
                    let lookAt = SCNLookAtConstraint(target: sphereNode)
                    camNode.constraints = [lookAt]
                case 4:
                    let planeNode = SCNNode()
                    let plane = SCNPlane(width: 1.1, height: 1.1)
                    
                    planeNode.geometry = plane
                    
                    planeNode.position = SCNVector3Make(CFloat(pX), 0.1, CFloat(pZ))
                    planeNode.rotation = SCNVector4Make(1, 0, 0, -90 * 0.0174532925)
                    mapRoot.addChildNode(planeNode)
                    planeNode.geometry!.firstMaterial = goalTex
                    planeNode.geometry!.firstMaterial!.emission.contents = UIColor.red
                default: break;
                }
            }
        }
        
        
        var flatClone = wallFlat.flattenedClone()
        
        mapRoot.addChildNode(flatClone)
        
        scene.rootNode.addChildNode(mapRoot)
        
        pushesLabel.text = "0"
        movesLabel.text = "0"
        storedLabel.text = "0"
    }
    
    
    @objc func pinch(recognizer: UIPinchGestureRecognizer) {
        
        let scale = recognizer.scale
        
        camNode.position.y *= Float(scale)
        
        recognizer.scale = 1;
    }
    
    
    @objc func swipe(gestureRecognize: UIGestureRecognizer) {
        
        if !isMoving {
            
            if let dirRecognise = gestureRecognize as? UISwipeGestureRecognizer {
                
                var moveVec = SCNVector3Zero
                switch(dirRecognise.direction) {
                case UISwipeGestureRecognizer.Direction.right:
                    moveVec = SCNVector3Make(1,0,0)
                case UISwipeGestureRecognizer.Direction.left:
                    moveVec = SCNVector3Make(-1,0,0)
                case UISwipeGestureRecognizer.Direction.up:
                    moveVec = SCNVector3Make(0,0,-1)
                case UISwipeGestureRecognizer.Direction.down:
                    moveVec = SCNVector3Make(0,0,1)
                default:break
                }
                
                var pos = sphereNode.position
                let newPos = SCNVector3Make(pos.x + moveVec.x, pos.y, pos.z + moveVec.z)
                
                
                let bWidth = newBoard.width
                let bHeight = newBoard.height
                
                let oX:Int = Int(pos.x) + (bWidth / 2)
                let oZ:Int = Int(pos.z) + (bHeight / 2)
                
                let pX:Int = Int(newPos.x) + (bWidth / 2)
                let pZ:Int = Int(newPos.z) + (bHeight / 2)
                
                
                if newBoard.canMoveTo(x: pX, y: pZ) {
                    isMoving = true
                    let action = SCNAction .move(to: newPos, duration: 0.2)
                    sphereNode.runAction(action, completionHandler: {
                        
                        self.isMoving = false
                    })
                    self.newBoard.movePiece(x: oX, y:oZ, nX:pX, nY:pZ)
                    self.newBoard.storeMove(x: oX, y:oZ, nX:pX, nY:pZ)
                }
                else if newBoard.boxAt(x: pX, y: pZ) {
                    let box:SCNNode? = mapRoot.childNode(withName: "\(pZ * bWidth + pX)", recursively: false)
                    if((box) != nil) {
                        print("Hit box")
                        let newBoxPos = SCNVector3Make(newPos.x + moveVec.x, newPos.y, newPos.z + moveVec.z)
                        
                        let bpX:Int = Int(newBoxPos.x) + (bWidth / 2)
                        
                        let bpZ:Int = Int(newBoxPos.z) + (bHeight / 2)
                        
                        if newBoard.canMoveTo(x: bpX, y: bpZ) {
                            isMoving = true
                            let action = SCNAction .move(to: newBoxPos, duration: 0.2)
                            box!.runAction(action, completionHandler: {
                                box!.name = "\(bpZ * bWidth + bpX)"
                            })
                            isMoving = true
                            let sphAction = SCNAction .move(to: newPos, duration: 0.2)
                            sphereNode.runAction(sphAction, completionHandler: {
                                self.isMoving = false
                                
                                
                            })
                            
                            
                            self.newBoard.movePiece(x: pX, y:pZ, nX:bpX, nY:bpZ)
                            self.newBoard.movePiece(x: oX, y:oZ, nX:pX, nY:pZ)
                            
                            //store the moves the opposite way around
                            
                            self.newBoard.storeMove(x: oX, y:oZ, nX:pX, nY:pZ)
                            self.newBoard.storeMove(x: pX, y:pZ, nX:bpX, nY:bpZ)
                            
                            if self.newBoard.levelComplete {
                                self.animateGameOver()
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        self.pushesLabel.text = "\(self.newBoard.numPushes)"
        self.movesLabel.text = "\(self.newBoard.numMoves)"
        self.storedLabel.text = "\(self.newBoard.boxesOnGoals)"
    }
    
    
    func animateGameOver() {
        self.levelFinishedHorizontalConstraint.constant = -16
        self.gameOverView.isHidden = false;
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: {
            
            self.gameOverView.layoutIfNeeded()
            
        }, completion: { finished in
            self.saveScore()
            let curLev = NSNumber(value: self.currentLevel + 1)
            UserDefaults.standard.set(curLev, forKey: "completedLevels")
            UserDefaults.standard.synchronize()
        })
    }
    
    
    func saveScore() {
        var levelsDict: NSDictionary? = UserDefaults.standard.object(forKey: "levelScores") as? NSDictionary
        if((levelsDict) == nil ) {
            
            levelsDict = NSMutableDictionary()
        }
        
        let saveDict = NSMutableDictionary()
        saveDict.setDictionary(levelsDict as! [AnyHashable : Any])
        
        let thisLevel = NSMutableDictionary()
        thisLevel.setValue("\(self.newBoard.numPushes)" as NSString, forKey: "PUSHES")
        thisLevel.setValue("\(self.newBoard.numMoves)" as NSString, forKey: "MOVES")
        
        saveDict.setValue(thisLevel, forKey: "level\(self.currentLevel)")
        
        UserDefaults.standard.set(saveDict, forKey: "levelScores")
        
        UserDefaults.standard.synchronize()
        
        let tdict: AnyObject! = UserDefaults.standard.object(forKey: "levelScores") as AnyObject
        
        print("\(tdict)")
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        _ = self.levelFinishedHorizontalConstraint.constant
        self.levelFinishedHorizontalConstraint.constant = -(size.width + 16)// / 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
        
        resetBoard()
    }
    
    
    @IBAction func undoPressed(sender: AnyObject) {
        didUndo()
    }
    
    
    @IBAction func continuePressed(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didUndo() {
        if self.newBoard.moves.isEmpty {
            return
        }
        
        print("DID UNDO DELEGATE")
        
        
        let dict = self.newBoard.moves.removeLast()
        
        print("dict \(dict)")
        
        let bWidth = newBoard.width
        let bHeight = newBoard.height
        let x = dict["x"]
        let y = dict["y"]
        let nX = dict["nX"]
        let nY = dict["nY"]
        
        if newBoard.boxAt(x: nX!, y: nY!) {
            let box:SCNNode? = mapRoot.childNode(withName: "\(nY! * bWidth + nX!)", recursively: false)
            if((box) != nil) {
                let obX:Int = Int(x!) - (bWidth / 2)
                let obZ:Int = Int(y!) - (bHeight / 2)
                box!.position = SCNVector3Make(CFloat(obX), 0.5, CFloat(obZ))
                box!.name = "\(y! * bWidth + x!)"
                print("\(box!.name)")
                
                
                
                let sphereDict = self.newBoard.moves.removeLast()
                let sx = sphereDict["x"]
                let sy = sphereDict["y"]
                let snX = sphereDict["nX"]
                let snY = sphereDict["nY"]
                
                let oX:Int = Int(sx!) - (bWidth / 2)
                let oZ:Int = Int(sy!) - (bHeight / 2)
                
                sphereNode.position = SCNVector3Make(CFloat(oX), 0.5, CFloat(oZ))
                
                self.newBoard.movePiece(x: snX!, y:snY!, nX:sx!, nY:sy!);
                
                self.newBoard.movePiece(x: nX!, y:nY!, nX:x!, nY:y!);
            }
            
        }
        else {
            let oX:Int = Int(x!) - (bWidth / 2)
            let oZ:Int = Int(y!) - (bHeight / 2)
            
            sphereNode.position = SCNVector3Make(CFloat(oX), 0.5, CFloat(oZ))
            self.newBoard.movePiece(x: nX!, y:nY!, nX:x!, nY:y!);
        }
    }
    
}
