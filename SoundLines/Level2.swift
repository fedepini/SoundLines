//
//  Level2.swift
//  SoundLines
//
//  Created by simona1971 on 25/06/19.
//  Copyright © 2019 Comelicode. All rights reserved.
//
// Level2: creates two elements, then a line between them, and detects if
// the user pans inside the line

import UIKit
import AudioKit
import AVFoundation

class Level2: UIViewController {
    
    //AudioKit setup and start
    
    var oscillator = AKFMOscillator()
    var oscillator2 = AKOscillator()
    var panner = AKPanner()
    var mixerCat = AKMixer()
    
    var catSound: AVAudioPlayer?
    var kittenSound: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationController?.navigationBar.isHidden = true;
        
        // Creates AudioKit mixer and panner
        
        let mixer = AKMixer(oscillator,oscillator2)
        
        panner = AKPanner(mixer, pan: 0.0)
        
        AudioKit.output = panner
        
        // Audio is played with silent mode as well
        
        AKSettings.playbackWhileMuted = true
        
        try! AudioKit.start()
        
        // Sets the width of the line image: 50% of screen height
        
        let frameHeight = view.frame.size.height * 0.5
        let aspectRatio = CGFloat(3)
        let frameWidth = frameHeight / aspectRatio
        
        redLine.frame = CGRect(x:0, y:0, width:frameWidth, height:frameHeight)
        
        // Sets dimensions of kitten and cat images
        
        kitten.frame = CGRect(x:0, y:0, width: frameWidth, height: frameWidth)
        cat.frame = CGRect(x:0, y:0, width: frameWidth, height: frameWidth)
        
        // Sets a frame for the images: the line image is centered horizontally and vertically
        // while kitten and cat are centered vertically and have some distance from the line image
        
        redLine.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.redLine.frame.width / 2)
        redLine.frame.origin.y = CGFloat(self.view.frame.size.height / 2 - self.redLine.frame.height / 2)
        
        kitten.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.kitten.frame.width / 2)
        kitten.frame.origin.y = redLine.frame.minY - kitten.frame.height - 10.0
        
        cat.frame.origin.x = CGFloat(self.view.frame.size.width / 2 - self.cat.frame.width / 2)
        cat.frame.origin.y = redLine.frame.maxY + 10.0
        
        // Hides the kitten label
        
        kitten.isHidden = true
        redLine.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            try! AudioKit.stop()
        }
    }
    
    
    @IBOutlet var kitten: UIImageView!
    @IBOutlet var cat: UIImageView!
    @IBOutlet var redLine: UIImageView!
    
    var gameStarted: Bool = false
    
    var catShown: Bool = false
    var levelComplete: Bool = false
    
    var startingPoint = CGPoint()
    var startedFromKitten: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Game logic: find the cat, find the kitten
        // When both are found create the line
        // If the kitten has been reached, go to the next level
        
        // Tell the user to find the cat
        
        if gameStarted == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                UIAccessibility.post(notification: .announcement, argument: "Find the cat")
            })
        }
    }
    
    // Sets the line location and dimension:
    // it is located between the cat and the kitten
    // it has the same heigth as the element
    
    // Detects panning on the shape and adds sonification based on the finger position
    
    var catFound = 0
    var kittenFound = 0
    var levelCompleteCounter = 0
    
    @IBAction func panDetector(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let catSoundPath = Bundle.main.path(forResource: "cat.wav", ofType:nil)!
        let catSoundUrl = URL(fileURLWithPath: catSoundPath)
        let kittenSoundPath = Bundle.main.path(forResource: "kitten.wav", ofType:nil)!
        let kittenSoundUrl = URL(fileURLWithPath: kittenSoundPath)
        
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
                
                // Show the kitten
                
                catFound = catFound + 1
                catShown = true
                kitten.isHidden = false
            } else {
                catFound = 0
            }
            
            if catShown == true {
                
                if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                    
                    startingPoint = initialPoint
                    print("startingPoint 2: ", startingPoint)
                    
                    print("kitten: tap")
                    
                    kittenFound = kittenFound + 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        
                        self.redLine.isHidden = false
                        
                        // Start the game
                        
                        self.gameStarted = true
                    })
                } else {
                    kittenFound = 0
                }
            }
        }
        
        if gameStarted == true {
            
            if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                startingPoint = initialPoint
                print("startingPoint 2: ", startingPoint)
                
                startedFromKitten = true
                
                UIAccessibility.post(notification: .announcement, argument: "Kitten")
                
            }
            
            if gestureRecognizer.state == .changed {
                print(initialPoint)
                
                // Distinguishes 3 cases based on the finger position:
                // 1. Inside the line but not in the center
                // 2. At the center of the line
                // 3. Outside the line
                
                // The finger is inside the line
                
                if (distPointLine(point: initialPoint) <= Double(redLine.frame.width / 2)) {
                    print("OK: point is inside shape, dist:", distPointLine(point: initialPoint))
                    
                    // 1. Inside the line but not in the center
                    
                    oscillator2.stop()
                    oscillator.baseFrequency = 300 + 10 * distPointLine(point: initialPoint)
                    oscillator.amplitude = 1
                    oscillator.start()
                    
                    if Utility.isInsideKitten(kitten: kitten, point: initialPoint) {
                        oscillator.stop()
                        UIAccessibility.post(notification: .announcement, argument: "Kitten")
                    } else if Utility.isInsideCat(cat: cat, point: initialPoint) {
                        oscillator.stop()
                        UIAccessibility.post(notification: .announcement, argument: "Cat")
                    }
                    
                    // 2. At the center of the line
                    
                    if (distPointLine(point: initialPoint) <= 5) {
                        print("Inside the middle line")
                        oscillator2.stop()
                        
                        panner.pan = Utility.normalizePannerValue(cat: cat, kitten: kitten, num: Double(initialPoint.x))
                        
                        oscillator.baseFrequency = 300
                    }
                    
                    if Utility.isInsideCat(cat: cat, point: initialPoint) {
                        print("Last point is inside element")
                        
                        if startedFromKitten {
                            oscillator.stop()
                            oscillator2.stop()
                            
                            gameStarted = false
                            
                            levelComplete = true
                            
                        }
                        
                    } else if !Utility.isInsideKitten(kitten: kitten, point: initialPoint) || startedFromKitten == false {
                        print("Last point is outside element")
                        print("restart game")
                        UIAccessibility.post(notification: .announcement, argument: "Go back and follow the line")
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
                    UIAccessibility.post(notification: .announcement, argument: "Go back and follow the line")
                    
                }
            }
            
            if gestureRecognizer.state == .ended {
                oscillator.stop()
                oscillator2.stop()
                print("Pan released")
                print("restart game")
                UIAccessibility.post(notification: .announcement, argument: "Go back and follow the line")
                startedFromKitten = false
                levelCompleteCounter = 0
            }
        }
        
        if levelComplete == true {
            
            gestureRecognizer.isEnabled = false
            
            UIAccessibility.post(notification: .announcement, argument: "Well done! Level 2 completed")
            
            do {
                self.catSound = try AVAudioPlayer(contentsOf: catSoundUrl)
                self.catSound?.play()
            } catch {
                // couldn't load file :(
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                try! AudioKit.stop()
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let level2Screen = storyBoard.instantiateViewController(withIdentifier: "Level3Screen")
                self.present(level2Screen, animated: true, completion: nil)
                
            })
        }
        
        if catFound == 1 {
            
            do {
                self.catSound = try AVAudioPlayer(contentsOf: catSoundUrl)
                self.catSound?.play()
            } catch {
                // couldn't load file :(
            }
            
            UIAccessibility.post(notification: .announcement, argument: "You found the cat! Find the kitten")
        }
        
        if kittenFound == 1 {
            
            do {
                kittenSound = try AVAudioPlayer(contentsOf: kittenSoundUrl)
                kittenSound?.play()
            } catch {
                // couldn't load file :(
            }
            
            UIAccessibility.post(notification: .announcement, argument: "You found the kitten! Follow the line to connect the kitten to the cat")
        }
    }

    func distPointLine(point: CGPoint) -> Double {
        let a = Double(1)
        let b = Double(0)
        let c = Double(self.view.frame.size.width / 2)
        
        let den = sqrt(pow(a, 2) + pow(b, 2))
        
        return abs(a * Double(point.x) + b * Double(point.y) - c) / den
    }
}
