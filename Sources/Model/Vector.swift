public struct Vector: Hashable, Sendable {
    public var x: Double
    public var y: Double
    
    public static let zero = Self(x: 0, y: 0)
    
    // this will be essentially a unit point so just use that.  Replace with a unit point.  Future might change to 3dVector...
    
    public static prefix func - (operand: Self) -> Self {
        return Self(x: -operand.x, y: -operand.y)
    }
    public static func - (lhs: Vector, rhs: Vector) -> Vector {
        return lhs + -rhs
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    public static func * (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        return Self(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    //    
    //    public init(x: Double, y: Double) {
    //        self.x = x
    //        self.y = y
    //    }
}
