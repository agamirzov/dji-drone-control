//
//  Line.swift
//  AeroGlaz
//
//  Created by Evgeny Agamirzov on 23.06.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import CoreGraphics

enum IntersectionError : Error {
    case parallel
    case overlap
}

class Line : Equatable {
    // Stored properties
    private(set) var a: CGFloat?
    private(set) var b: CGFloat?
    private(set) var x: CGFloat?

    // Create line from vector
    convenience init(vector: Vector) {
        if vector.dx == 0 {
            self.init(a: nil, b: nil, x: vector.startPoint.x)
        } else {
            let a = vector.dy / vector.dx
            let b = vector.startPoint.y - a * vector.startPoint.x
            self.init(a: a, b: b)
        }
    }

    // Create vertical line
    convenience init(x: CGFloat) {
        self.init(angle: GeometryUtils.pi / 2, point: CGPoint(x: x, y: 0))
    }

    // Create line from angle (radian) and point
    convenience init(angle: CGFloat, point: CGPoint) {
        if angle == GeometryUtils.pi / 2 {
            self.init(a: nil, b: nil, x: point.x)
        } else {
            self.init(a: tan(angle), b: point.y - tan(angle) * point.x)
        }
    }

    // Create line from coefficients
    init(a: CGFloat?, b: CGFloat?, x: CGFloat? = nil) {
        self.a = a
        self.b = b
        self.x = x
    }
}

// Public methods
extension Line {
    func contains(_ point: CGPoint) -> Bool {
        return x == nil ? (point.y == a! * point.x - b!) : (x! == point.x)
    }

    func intersectionPoint(with line: Line) -> Result<CGPoint, IntersectionError> {
        // Both lines vertical
        if x != nil && line.x != nil {
            if x! == line.x! {
                return .failure(.overlap)
            } else {
                return .failure(.parallel)
            }
        }
        // First line vertical
        else if x != nil {
            return .success(CGPoint(x: x!, y: line.a! * x! + line.b!))
        }
        // Second line vertical
        else if line.x != nil {
            return .success(CGPoint(x: line.x!, y: a! * line.x! + b!))
        }
        // Lines have same tangent
        else if a == line.a {
            if b == line.b {
                return .failure(.overlap)
            } else {
                return .failure(.parallel)
            }
        }
        // Generic case
        else {
            let x = (line.b! - b!) / (a! - line.a!)
            return .success(CGPoint(x: x, y: a! * x + b!))
        }
    }
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.x == rhs.x
}
