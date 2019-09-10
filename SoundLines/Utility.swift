//
//  Utility.swift
//  
//
//  Created by Fede on 23/08/19.
//

import Foundation
import UIKit

class Utility {

    // Returns true if the given point is inside the cat image
 
    class func isInsideCat(cat: UIImageView, point: CGPoint) -> Bool {
        let catMaxX = cat.frame.maxX
        let catMinX = cat.frame.minX
        let catMaxY = cat.frame.maxY
        let catMinY = cat.frame.minY

        return point.x >= catMinX && point.x <= catMaxX &&
        point.y >= catMinY && point.y <= catMaxY
    }
    
    // Returns true if the given point is inside the kitten image
    
    class func isInsideKitten(kitten: UIImageView, point: CGPoint) -> Bool {
        let kittenMaxX = kitten.frame.maxX
        let kittenMinX = kitten.frame.minX
        let kittenMaxY = kitten.frame.maxY
        let kittenMinY = kitten.frame.minY
        
        return point.x >= kittenMinX && point.x <= kittenMaxX &&
            point.y >= kittenMinY && point.y <= kittenMaxY
    }
    
    // Normalizes double values for AudioKit panner
    
    class func normalizePannerValue(cat: UIImageView, kitten: UIImageView, num: Double) -> Double {
        let min = Double(kitten.frame.minX + 10)
        let max = Double(cat.frame.maxX - 10)
        return 2 * ((num - min) / (max - min)) - 1
    }
}
