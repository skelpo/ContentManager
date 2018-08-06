import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get(any, "content", "health") { _ in
        return "all good"
    }
    
    try router.register(collection: VersionedCollection())
}

