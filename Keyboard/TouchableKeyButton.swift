import UIKit

class TouchableKeyButton: UIButton {
    enum KeyType {
        case letter
        case number
        case symbol
        case modifier
        case spacebar
    }
    
    var keyType: KeyType = .letter
    var config: TouchDetectionConfig = TouchDetectionConfig() {
        didSet {
            updateDebugOverlay()
        }
    }
    
    private var debugOverlayLayer: CAShapeLayer?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = getInsets()
        let expandedBounds = bounds.inset(by: insets)
        return expandedBounds.contains(point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDebugOverlay()
    }
    
    private func getInsets() -> UIEdgeInsets {
        switch keyType {
        case .letter, .number, .symbol:
            return UIEdgeInsets(
                top: config.verticalInsetAbove,
                left: config.horizontalInset,
                bottom: config.verticalInsetBelow,
                right: config.horizontalInset
            )
        case .modifier:
            return UIEdgeInsets(
                top: config.modifierKeyInset,
                left: config.modifierKeyInset,
                bottom: config.modifierKeyInset,
                right: config.modifierKeyInset
            )
        case .spacebar:
            return UIEdgeInsets(
                top: config.spaceBarInset,
                left: config.spaceBarInset,
                bottom: config.spaceBarInset,
                right: config.spaceBarInset
            )
        }
    }
    
    private func updateDebugOverlay() {
        debugOverlayLayer?.removeFromSuperlayer()
        debugOverlayLayer = nil
        
        guard config.showHitZoneOverlay else { return }
        
        let insets = getInsets()
        let expandedBounds = bounds.inset(by: insets)
        
        let overlayLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: expandedBounds, cornerRadius: 3)
        overlayLayer.path = path.cgPath
        
        // Different colors for different key types
        let overlayColor: UIColor
        switch keyType {
        case .letter:
            overlayColor = UIColor.systemBlue.withAlphaComponent(0.2)
        case .number:
            overlayColor = UIColor.systemGreen.withAlphaComponent(0.2)
        case .symbol:
            overlayColor = UIColor.systemPurple.withAlphaComponent(0.2)
        case .modifier:
            overlayColor = UIColor.systemOrange.withAlphaComponent(0.2)
        case .spacebar:
            overlayColor = UIColor.systemRed.withAlphaComponent(0.2)
        }
        
        overlayLayer.fillColor = overlayColor.cgColor
        overlayLayer.strokeColor = overlayColor.withAlphaComponent(0.5).cgColor
        overlayLayer.lineWidth = 1
        
        layer.insertSublayer(overlayLayer, at: 0)
        debugOverlayLayer = overlayLayer
    }
}
