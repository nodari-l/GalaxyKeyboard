import Foundation
import CoreGraphics

struct TouchDetectionConfig {
    var horizontalInset: CGFloat = -3.0
    var verticalInsetAbove: CGFloat = -5.0
    var verticalInsetBelow: CGFloat = -3.0
    
    var maxGapDetectionDistance: CGFloat = 25.0
    
    var verticalBias: CGFloat = 1.2
    
    var modifierKeyInset: CGFloat = -1.0
    var spaceBarInset: CGFloat = -5.0
    
    var showHitZoneOverlay: Bool = false
}
