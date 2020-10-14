//
//  TriangleView.swift
//  IsolinesDemo
//
//  Created by Reid van Melle on 2020-10-12.
//

import UIKit
import GameplayKit
import DelaunayTriangulation
import MarchingSquares

/// Generate set of points for our triangulation to use
func generateVertices(_ size: CGSize, cellSize: CGFloat, variance: CGFloat = 0.75, seed: UInt64 = UInt64.random(in: 0..<UInt64.max)) -> [MarchingSquares.Point] {

    // How many cells we're going to have on each axis (pad by 2 cells on each edge)
    let cellsX = (size.width + 4 * cellSize) / cellSize
    let cellsY = (size.height + 4 * cellSize) / cellSize

    // figure out the bleed widths to center the grid
    let bleedX = ((cellsX * cellSize) - size.width)/2
    let bleedY = ((cellsY * cellSize) - size.height)/2

    let _variance = cellSize * variance / 4

    var points = [MarchingSquares.Point]()
    let minX = -bleedX
    let maxX = size.width + bleedX
    let minY = -bleedY
    let maxY = size.height + bleedY

    let generator = GKLinearCongruentialRandomSource(seed: seed)

    for i in stride(from: minX, to: maxX, by: cellSize) {
        for j in stride(from: minY, to: maxY, by: cellSize) {

            let x = i + cellSize/2 + CGFloat(generator.nextUniform()) + CGFloat.random(in: -_variance..._variance)
            let y = j + cellSize/2 + CGFloat(generator.nextUniform()) + CGFloat.random(in: -_variance..._variance)
            let foo = abs(x - size.width/2.0) + abs(y - size.height/2.0)
            var altitude: Double = Double(pow(foo, 1.15))
            if x > 300 {
                altitude -= 200
            }
            if y < 200 {
                altitude *= 1.3
            }
            if y > 400 {
                altitude -= 300
            }

            points.append(Point(x: Double(x), y: Double(y), altitude: altitude))
        }
    }

    return points
}

class TriangleView: UIView {
    var triangles: [(DelaunayTriangulation.Triangle, CAShapeLayer)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: 200, height: 400)
//        // return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
//    }
//
//    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
//        return targetSize
//    }

//    override func didMoveToSuperview() {
//        initTriangles()
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        initTriangles()
    }

    func initTriangles() {
        for (_, triangleLayer) in triangles {
            triangleLayer.removeFromSuperlayer()
        }

        let points = generateVertices(bounds.size, cellSize: 80)
        let pointMap = points.reduce(into: [DelaunayTriangulation.Point: MarchingSquares.Point]()) { (currentMap, point) in
            currentMap[DelaunayTriangulation.Point(x: point.x, y: point.y)] = point
        }
//        let simplePoints = points.map { (point) -> DelaunayTriangulation.Point in
//            return DelaunayTriangulation.Point(x: point.x, y: point.y)
//        }
        let delaunayPoints: [DelaunayTriangulation.Point] = Array(pointMap.keys)
        let delaunayTriangles = triangulate(delaunayPoints)
        let triangleWithAltitudes = delaunayTriangles.map { (delauneyTriangle) -> MarchingSquares.Triangle in
            return MarchingSquares.Triangle(point1: pointMap[delauneyTriangle.point1]!, point2: pointMap[delauneyTriangle.point2]!, point3: pointMap[delauneyTriangle.point3]!)
        }

//        let contour = computeContours(triangles: triangles.map({ (triangle, _) -> DelaunayTriangulation.Triangle in
//            triangle
//        }), contour: 50)

        triangles = []
        for triangle in delaunayTriangles {
            let triangleLayer = CAShapeLayer()
            triangleLayer.path = triangle.toPath()
            triangleLayer.fillColor = UIColor().randomColor().cgColor
            triangleLayer.backgroundColor = UIColor.clear.cgColor
            layer.addSublayer(triangleLayer)

            triangles.append((triangle, triangleLayer))
        }

        let isoLines: [Double] = [-50, 0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750]
        // let isoLines: [Double] = [-50, 0, 50, 100, 150]
        // let isoLines: [Double] = [-50, 0, 50, 100, 150, 200, 250, 300, 350, 400, 450]
        for iso in Array<Double>(isoLines) {
            let contours = computeIsolineContours(triangles: triangleWithAltitudes, contour: iso)
            if contours.isEmpty {
                continue
            }
            for contour in contours {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: contour.first!.x, y: contour.first!.y))
                for point in contour {
                    path.addLine(to: CGPoint(x: point.x, y: point.y))
                }
                // path.closeSubpath()
                let s = CAShapeLayer()
                s.path = path
                s.strokeColor = UIColor.green.cgColor
                s.fillColor = UIColor.clear.cgColor
                s.lineWidth = 2.0
                layer.addSublayer(s)
            }
        }

        for iso in Array<Double>(isoLines) {
            let contour = computeContourLineSegments(triangles: triangleWithAltitudes, contour: iso)
            for segment in contour {
                let s = CAShapeLayer()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: segment.point1.x, y: segment.point1.y))
                path.addLine(to: CGPoint(x: segment.point2.x, y: segment.point2.y))
                s.path = path
                s.strokeColor = UIColor.black.cgColor
                s.lineWidth = 0.5
                layer.addSublayer(s)
            }
        }


    }

    @IBAction func singleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let tapLocation = recognizer.location(in: self)
            let vertex = Point(point: tapLocation)
            for (triangle, triangleLayer) in triangles {
                if vertex.inside(triangle) {
                    triangleLayer.fillColor = UIColor.black.cgColor
                }
            }
        }
    }

    @IBAction func doubleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            initTriangles()
        }
    }
}

