//
//  IntroductionScreen.swift
//  SoundLines
//
//

import UIKit

class Level1Screen: UIViewController {
    
    // Variables
    
    @IBOutlet var screenButton: UIButton!
    @IBOutlet var screenTitle: UILabel!
    @IBOutlet var screenText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets view elements dimension and position
        
        setViewElements()
        
        // Hides back button and navigation bar
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationController?.navigationBar.isHidden = true;
        
        // Reads label if VoiceOver is activated
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            UIAccessibility.post(notification: .announcement, argument: "First, find the cat and the kitten. Then connect the kitten to the cat following the horizontal line. The sound will help you to know if it's the right path. Press play to continue.")
        })
    }
    
    // FUNCTIONS
    
    // 1. ONLOAD FUNCTIONS
    
    // setViewElements: sets positions and dimensions of view elements: they are centered vertically and their dimension depends on screen width and height
    
    func setViewElements() -> Void {
        
        print("setViewElements")
     
        let screenWidth = view.frame.width
        let screenHeight = view.frame.size.height
        
        // Sets title dimension and position
        
        screenTitle.sizeToFit()
        screenTitle.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.2)
        screenTitle.center.x = self.view.center.x
        screenTitle.center.y = self.view.center.y - screenHeight * 0.3
        
        // Sets text dimension and position

        screenText.sizeToFit()
        screenText.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.8, height: screenHeight * 0.4)
        screenText.center = self.view.center
        
        // Sets different multiplication constant for iPhone or iPad button

        var screenHeighMultiplicationConstant = CGFloat()
        if screenWidth >= 1024 {
            screenHeighMultiplicationConstant = 0.15
        } else {
            screenHeighMultiplicationConstant = 0.2
        }
        
        // Sets button dimension and position
        
        screenButton.sizeToFit()
        screenButton.frame = CGRect(x: 0, y: 0, width: screenWidth * 0.3, height: screenHeight * screenHeighMultiplicationConstant)
        screenButton.center.x = self.view.center.x
        screenButton.center.y = self.view.center.y + screenHeight * 0.3
        
    }
}
