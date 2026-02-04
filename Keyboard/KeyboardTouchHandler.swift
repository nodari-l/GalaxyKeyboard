import UIKit

class KeyboardTouchHandler {
    struct TouchCandidate {
        let button: UIButton
        let distance: CGFloat
        let isDirectHit: Bool
    }
    
    var config: TouchDetectionConfig
    var allButtons: [UIButton]
    
    init(config: TouchDetectionConfig, allButtons: [UIButton]) {
        self.config = config
        self.allButtons = allButtons
    }
    
    func handleTouch(at point: CGPoint, in view: UIView) -> UIButton? {
        var directHitCandidates: [TouchCandidate] = []
        
        for button in allButtons {
            let localPoint = view.convert(point, to: button)
            if button.point(inside: localPoint, with: nil) {
                let distance = calculateDistance(from: point, to: button, in: view)
                directHitCandidates.append(TouchCandidate(button: button, distance: distance, isDirectHit: true))
            }
        }
        
        if !directHitCandidates.isEmpty {
            let nearest = directHitCandidates.min(by: { $0.distance < $1.distance })
            return nearest?.button
        }
        
        return findNearestKey(to: point, in: view)
    }
    
    func findNearestKey(to point: CGPoint, in view: UIView) -> UIButton? {
        var candidates: [TouchCandidate] = []
        
        for button in allButtons {
            let distance = calculateDistance(from: point, to: button, in: view)
            if distance <= config.maxGapDetectionDistance {
                candidates.append(TouchCandidate(button: button, distance: distance, isDirectHit: false))
            }
        }
        
        if candidates.isEmpty {
            return nil
        }
        
        let nearest = candidates.min(by: { $0.distance < $1.distance })
        return nearest?.button
    }
    
    func calculateDistance(from point: CGPoint, to button: UIButton, in view: UIView) -> CGFloat {
        let buttonCenter = view.convert(button.center, from: button.superview)
        
        let dx = point.x - buttonCenter.x
        let dy = point.y - buttonCenter.y
        var distance = sqrt(dx * dx + dy * dy)
        
        if point.y > buttonCenter.y {
            distance *= config.verticalBias
        }
        
        return distance
    }
}
