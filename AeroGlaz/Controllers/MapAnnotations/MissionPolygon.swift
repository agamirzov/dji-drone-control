//
//  MissionRenderer.swift
//  Aeroglaz
//
//  Created by Evgeny Agamirzov on 24.12.19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import UIKit
import MapKit

fileprivate let maxVertexCount: Int = 20

class MissionPolygon : MKPolygon {
    // Stored properties
    var vertexArea = MissionRenderer.vertexRadius
    var pointSet = Points()
    private var vertexOffsets: [CGPoint] = []
    private var missionGrid: [CGPoint] = []
    private var vertexCount: Int = 0
    private var draggedVertexId: Int?

    // Observer properties
    weak var renderer: MissionRenderer? {
        didSet {
            for id in 0..<vertexCount {
                pointSet.points.append(renderer!.point(for: points()[id]))
            }
        }
    }
    var gridDistance: CGFloat? {
        didSet {
            renderer?.redrawRenderer()
        }
    }
    var gridAngle: CGFloat? {
        didSet {
            renderer?.redrawRenderer()
        }
    }
    var missionState: MissionState? {
        didSet {
            renderer?.missionState = missionState
        }
    }
    var aircraftLocation: CLLocation? {
        didSet {
            renderer?.redrawRenderer()
        }
    }

    convenience init(_ coordinates: [CLLocationCoordinate2D]) {
        let vertexCount = coordinates.count
        var preallocatedCoordinates = Array(repeating: CLLocationCoordinate2D(), count: maxVertexCount)
        preallocatedCoordinates.replaceSubrange(0...vertexCount - 1, with: coordinates)
        self.init(coordinates: preallocatedCoordinates, count: maxVertexCount)
        self.vertexCount = vertexCount
    }
}

// Public methods
extension MissionPolygon {
    func addVetrex(at coordinate: CLLocationCoordinate2D, redraw: Bool) {
        pointSet.points.append(renderer!.point(for: MKMapPoint(coordinate)))
        updateVertex(coordinate, id: vertexCount, redraw: redraw)
        vertexCount += 1
    }

    func removeVetrex() {
        if draggedVertexId != nil && vertexCount > 3 {
            pointSet.points.remove(at: draggedVertexId!)
            let maxCount = (vertexCount == maxVertexCount) ? (maxVertexCount - 1) : (vertexCount - 1)
            for id in draggedVertexId!..<maxCount {
                points()[id] = points()[id + 1]
            }
            vertexCount -= 1
            renderer?.redrawRenderer()
        }
    }

    func setRawMissionCoordinates( _ coordinates: [[Double]]) {
        if coordinates.count >= 3 {
            pointSet.points.removeAll()
            for i in 0..<maxVertexCount {
                points()[i] = MKMapPoint()
            }
            vertexCount = 0
            for coordinate in coordinates {
                let lat = coordinate[1]
                let lon = coordinate[0]
                addVetrex(at: CLLocationCoordinate2D(latitude: lat, longitude: lon), redraw: false)
            }
            renderer?.redrawRenderer()
        }
    }

    func missionCoordinates() -> [CLLocationCoordinate2D] {
        if renderer != nil {
            var coordinates: [CLLocationCoordinate2D] = []
            for point in renderer!.meander {
                coordinates.append(renderer!.mapPoint(for: point).coordinate)
            }
            return coordinates
        } else {
            return []
        }
    }

    func bodyContainsCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if renderer != nil {
            let rect = pointSet.rect.rect
            let polygonOrigin = renderer!.mapPoint(for: rect.origin)
            let polygonSize = MKMapSize(width: Double(rect.width), height: Double(rect.height))
            let polygonRect = MKMapRect(origin: polygonOrigin, size: polygonSize)
            return polygonRect.contains(MKMapPoint(coordinate))
        } else {
            return false
        }
    }

    func vertexContainsCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if renderer != nil {
            for id in 0..<vertexCount {
                let vertexPosition = renderer!.point(for: points()[id])
                let touchPosition = renderer!.point(for: MKMapPoint(coordinate))
                let distance = Vector(vertexPosition, touchPosition).norm
                if distance < vertexArea {
                    draggedVertexId = id
                    return true
                }
            }
            draggedVertexId = nil
            return false
        } else {
            draggedVertexId = nil
            return false
        }
    }

    func computeCenter() -> CLLocationCoordinate2D {
        var lat = CLLocationDegrees()
        var lon = CLLocationDegrees()
        for id in 0..<vertexCount {
            lat += points()[id].coordinate.latitude
            lon += points()[id].coordinate.longitude
        }
        return CLLocationCoordinate2D(latitude: lat / Double(vertexCount),
                                      longitude: lon / Double(vertexCount))
    }

    func computeVertexOffsets(relativeTo coordinate: CLLocationCoordinate2D) {
        vertexOffsets.removeAll(keepingCapacity: true)
        for id in 0..<vertexCount {
            let dLat = points()[id].coordinate.latitude - coordinate.latitude
            let dLon = points()[id].coordinate.longitude - coordinate.longitude
            vertexOffsets.append(CGPoint(x: dLat, y: dLon))
        }
    }

    func movePolygon(to coordinate: CLLocationCoordinate2D) {
        for id in 0..<vertexOffsets.count {
            let lat = coordinate.latitude + CLLocationDegrees(vertexOffsets[id].x)
            let lon = coordinate.longitude + CLLocationDegrees(vertexOffsets[id].y)
            updateVertex(CLLocationCoordinate2D(latitude: lat, longitude: lon), id: id, redraw: false)
        }
        // Redraw manually only after all points are updated
        renderer?.redrawRenderer()
    }

    func moveVertex(to coordinate: CLLocationCoordinate2D) {
        if draggedVertexId != nil && vertexOffsets.count >= draggedVertexId! {
            let lat = coordinate.latitude + CLLocationDegrees(vertexOffsets[draggedVertexId!].x)
            let lon = coordinate.longitude + CLLocationDegrees(vertexOffsets[draggedVertexId!].y)
            updateVertex(CLLocationCoordinate2D(latitude: lat, longitude: lon), id: draggedVertexId!, redraw: true)
        }
    }
}

// Private methods
extension MissionPolygon {
    private func updateVertex(_ coordinate: CLLocationCoordinate2D, id: Int, redraw: Bool) {
        if renderer != nil {
            points()[id] = MKMapPoint(coordinate)
            pointSet.points[id] = renderer!.point(for: points()[id])
            if redraw {
                renderer!.redrawRenderer()
            }
        }
    }
}
