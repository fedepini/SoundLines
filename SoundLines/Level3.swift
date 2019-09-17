//
//  Level3.swift
//  SoundLines
//
//  Created by Fede on 21/07/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//
// Level3: creates two elements, then a line between them, and detects if
// the user pans inside the line

import UIKit
import AudioKit

class Level3: UIViewController {
    
    // AudioKit setup and start
    
    var oscillator = AKFMOscillator()
    var oscillator2 = AKOscillator()
    var panner = AKPanner()
    
    var catSound: AKAudioPlayer!
    var kittenSound: AKAudioPlayer!
    
    // Variables
    
    @IBOutlet var kitten: UIImageView!
    @IBOutlet var cat: UIImageView!
    @IBOutlet var redLine: UIImageView!
    
    var gameStarted: Bool = false
    var levelComplete: Bool = false

    var startedFromKitten: Bool = false
    var catShown: Bool = false
    
    var catFound = 0
    var kittenFound = 0
    
    var diagonalAngle = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationController?.navigationBar.isHidden = true;
        
        // Inizialization of AudioKit elements: cat and kitten sounds, oscillators
        
        setAudioKitElements()
        
        // Sets positions and dimensions of view elements
        
        setViewElements()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            try! AudioKit.stop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Tell the user to find the cat
        
        if gameStarted == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                UIAccessibility.post(notification: .announcement, argument: "Find the cat")
            })
        }
    }
    
    // Game logic: find the cat, find the kitten
    // When both are found show the line
    // If the cat has been reached, go to the next level
    
    // Detects panning on the shape and adds sonification based on the finger position
    
    @IBAction func panDetector(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        print("panDetector")
        
        // Saves the point touched by the user
        
        let initialPoint = gestureRecognizer.location(in: view)
        
        guard gestureRecognizer.view != nil else {return}
        
        // Updates the position for the .began, .changed, and .ended states
        
        if gameStarted == false && levelComplete == false {
            
            if Utility.isInsideCat(cat: cat, point: initialPoint) {
                
                // If it is the first time finding the cat tell the user it has been found
                // and show the kitten
                // else tell the user it is the cat
                
                print("cat: first tap")
                
                if catFound == 0 {
                    UIAccessibility.post(notification: .announcement, argument: "You found the cat! Find the kitten")
                }
                
                catFound = catFound + 1
                
                catSound.start()
                
                // Show the kitten
                catShown = true
                kitten.isHidden = false
            }
            
            if catShown == true {
                
                if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                    
                    print("kitten: tap")
                    
                    if kittenFound == 0 {
                        UIAccessibility.post(notification: .announcement, argument: "You found the kitten! Follow the line to connect the kitten to the cat")
                    }
                    
                    kittenFound = kittenFound + 1
                    
                    kittenSound.start()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        
                        self.redLine.isHidden = false
                        
                        // Start the game
                        
                        self.gameStarted = true
                    })
                }
            }
        }
        
        if gameStarted == true {
            
            if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                
                startedFromKitten = true
                
            }
            
            if gestureRecognizer.state == .changed {
                print(initialPoint)                
                
                // Distinguishes 3 cases based on the finger position:
                // 1. Inside the line but not in the center
                // 2. At the center of the line
                // 3. Outside the line
                
                // The finger is inside the line
                
                let frameWidth = view.frame.size.width * 0.6
                let aspectRatio = CGFloat(5.336)
                let frameHeight = frameWidth / aspectRatio
                
                if (distPointLine(point: initialPoint) <= Double(frameHeight / 2)) {
                    
                    
                    if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                        oscillator2.stop()
                        oscillator.stop()
                        kittenSound.start()
                    } else if Utility.isInsideCat(cat: cat, point: initialPoint) {
                        oscillator2.stop()
                        oscillator.stop()
                        catSound.start()
                    }
                    
                    if isBetweenCats(cat: cat, kitten: kitten, point: initialPoint) {
                        print("OK: point is inside shape, dist:", distPointLine(point: initialPoint))
                        
                        // 1. Inside the line but not in the center
                        
                        oscillator2.stop()
                        oscillator.baseFrequency = 300 + 10 * distPointLine(point: initialPoint)
                        oscillator.amplitude = 1
                        oscillator.start()
                        
                        
                        // 2. At the center of the line
                        
                        if (distPointLine(point: initialPoint) <= 5) {
                            print("Inside the middle line")
                            oscillator2.stop()
                            
                            panner.pan = Utility.normalizePannerValue(cat: cat, kitten: kitten, num: Double(initialPoint.x))
                            
                            oscillator.baseFrequency = 300
                        }
                        
                        if Utility.isInsideCat(cat: cat, point: initialPoint) {
                            
                            if startedFromKitten {
                                print("Last point is inside element")
                                oscillator.stop()
                                oscillator2.stop()
                                
                                gameStarted = false
                                
                                levelComplete = true
                                
                            } else {
                                print("Last point is outside element")
                                print("restart game")
                                UIAccessibility.post(notification: .announcement, argument: "Go back to the kitten and follow the line")
                            }
                        }
                    }
                    
                } else {
                    // 3. Outside the line
                    
                    print("NO: point is outside shape")
                    
                    panner.pan = 0.0
                    
                    oscillator.stop()
                    oscillator2.amplitude = 0.5
                    oscillator2.frequency = 200
                    oscillator2.start()
                    
                    startedFromKitten = false
                    
                    print("restart game")
                }
            }
            
            if gestureRecognizer.state == .ended {
                oscillator.stop()
                oscillator2.stop()
                print("Pan released")
                print("restart game")
                UIAccessibility.post(notification: .announcement, argument: "Touch released, go back to the kitten and follow the line")
                startedFromKitten = false
            }
        }
        
        if levelComplete == true {
            
            gestureRecognizer.isEnabled = false
            
            UIAccessibility.post(notification: .announcement, argument: "Well done! Level 3 completed")
            
            catSound.start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                try! AudioKit.stop()
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let finalScreen = storyBoard.instantiateViewController(withIdentifier: "FinalScreen")
                self.present(finalScreen, animated: true, completion: nil)
                
            })
        }
    }
    
    // FUNCTIONS
    
    // Inizialization of AudioKit elements: cat and kitten sounds, oscillators
    
    func setAudioKitElements() -> Void {
        
        print("setAudioKitElements")
        
        // Creates AudioKit mixer and panner: adds cat and kitten sound
        
        let catFile = try! AKAudioFile(readFileName: "cat.wav")
        let kittenFile = try! AKAudioFile(readFileName: "kitten.wav")
        
        catSound = try! AKAudioPlayer(file: catFile)
        kittenSound = try! AKAudioPlayer(file: kittenFile)
        
        let mixer = AKMixer(oscillator, oscillator2, catSound, kittenSound)
        
        panner = AKPanner(mixer, pan: 0.0)
        
        AudioKit.output = panner
        
        // Audio is played with silent mode as well
        
        AKSettings.playbackWhileMuted = true
        
        try! AudioKit.start()
    }
    
    // Sets positions and dimensions of view elements
    
    func setViewElements() -> Void {
        
        print("setViewElements")

        // Sets the width of the line image: 40% of screen width
        
        let frameWidth = view.frame.size.width * 0.6
        let aspectRatio = CGFloat(5.336)
        let frameHeight = frameWidth / aspectRatio
        
        redLine.frame = CGRect(x:0, y:0, width:frameWidth, height:frameHeight)
        
        // Sets dimensions of kitten and cat images
        
        kitten.frame = CGRect(x:0, y:0, width: frameHeight, height: frameHeight)
        cat.frame = CGRect(x:0, y:0, width: frameHeight, height: frameHeight)
        
        // Sets a frame for the images: the line image is centered horizontally and vertically
        
        redLine.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.redLine.frame.width / 2)
        redLine.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - self.redLine.frame.height / 2)
        
        // Hides the kitten label
        
        kitten.isHidden = true
        
        // Hides the graphical line
        
        redLine.isHidden = true
        
        // Calculates diagonalAngle and rotates the image representing the line accordingly
        
        diagonalAngle = Double(atan(self.view.frame.size.height / self.view.frame.size.width))
        self.redLine.transform = CGAffineTransform(rotationAngle: CGFloat(diagonalAngle))
        
        // Sets the position of the kitten and cat images: they are placed on the diagonal line
        // between the two screen angles
        
        let kittenMinX = redLine.frame.minX - kitten.frame.size.width / 2
        let kittenMinY = redLine.frame.minY - kitten.frame.size.height / 2
        let kittenOldCenter = CGPoint(x:kittenMinX, y:kittenMinY)
        
        let kittenDistance = distPointLine(point: kittenOldCenter)
        
        kitten.frame.origin.x = kittenMinX - CGFloat(kittenDistance)
        kitten.frame.origin.y = kittenMinY
        
        let catMaxX = redLine.frame.maxX - cat.frame.size.width / 2
        let catMaxY = redLine.frame.maxY - cat.frame.size.height / 2
        let catOldCenter = CGPoint(x:catMaxX, y:catMaxY)
        
        let catDistance = distPointLine(point: catOldCenter)
        print(catDistance)
        
        cat.frame.origin.x = catMaxX + 11 * CGFloat(catDistance)
        cat.frame.origin.y = catMaxY - CGFloat(catDistance)
    }

    // Creates a virtual line based on an equation: returns distance from given point
    
    func distPointLine(point: CGPoint) -> Double {
        
        print("distPointLine")

        let a = Double(1)
        let b = Double(1)
        
        let m = tan(diagonalAngle)
        
        let den = sqrt(1 + pow(m, 2))
        
        return abs(b * Double(point.y) - (m * a * Double(point.x) + 146.0/333.0)) / den
    }
    
    // Returns true if the given point is between the cat and kitten image
    
    func isBetweenCats(cat: UIImageView, kitten: UIImageView, point: CGPoint) -> Bool {
        
        print("isBetweenCats")

        let kittenMaxX = kitten.frame.maxX
        let catMaxX = cat.frame.maxX
        
        return point.x >= kittenMaxX && point.x <= catMaxX
    }
}
