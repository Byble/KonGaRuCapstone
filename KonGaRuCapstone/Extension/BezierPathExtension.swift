import Foundation
import Cocoa

extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points: [CGPoint] = Array<CGPoint>(repeating: .zero, count: 3)
        
        for idx in 0 ..< self.elementCount {
            let type = self.element(at: idx, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        return path
    }
}

extension NSBezierPath{
    open func addQuadCurve(to point: CGPoint, controlPoint: CGPoint) {
        let (d1x, d1y) = (controlPoint.x - currentPoint.x, controlPoint.y - currentPoint.y)
        let (d2x, d2y) = (point.x - controlPoint.x, point.y - controlPoint.y)
        let cp1 = CGPoint(x: controlPoint.x - d1x / 3.0, y: controlPoint.y - d1y / 3.0)
        let cp2 = CGPoint(x: controlPoint.x + d2x / 3.0, y: controlPoint.y + d2y / 3.0)
        self.curve(to: point, controlPoint1: cp1, controlPoint2: cp2)
    }
}
