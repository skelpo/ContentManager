import Vapor
import FluentMySQL


final class ContentController: RouteCollection {
    
    func boot(router: Router) {
        router.get(String.parameter, use: index)
        router.get("byId", String.parameter, use: byId)
        /*router.get("attributes", use: attributes)
        
        router.post(NewUserB    ody.self, at: "profile", use: save)
        router.post(AttributeBody.self, at: "attributes", use: createAttribute)
        
        router.delete("attribute", use: deleteAttributes)
        router.delete("user", use: delete)*/
    }
    
    func byId(_ req: Request) throws -> Future<[Item]> {
        let type = try req.parameters.next(String.self)
        let ids_ = ""
        
        do {
            ids_ = try req.query.get(String.self, at: "ids")
        }
        catch {}
        
        let ids = ids_.split(separator: ",")
        
        return Item.query(on: req).filter(\.type == type).filter(\Item.id ~~ ids).all()
    }
    

    func index(_ req: Request) throws -> Future<[Item]> {
        let type = try req.parameters.next(String.self)
        var sortBy = "publishedAt"
        var ascending = false
        var offset = 0
        var limit = 10
        do {
            sortBy = try req.query.get(String.self, at: "sortBy")
        }
        catch {}
        do {
            ascending = try req.query.get(Bool.self, at: "asc")
        }
        catch {}
        do {
            offset = try req.query.get(Int.self, at: "offset")
        }
        catch {}
        do {
            limit = try req.query.get(Int.self, at: "limit")
        }
        catch {}
        if limit > 1000 {
            limit = 1000
        }
        if offset < 0 {
            offset = 0
        }
        if limit < 0 {
            limit = 0
        }
        var sortingType = MySQLDirection.ascending
        if ascending == false {
            sortingType = MySQLDirection.descending
        }
        var sortByVar = \Item.publishedAt
        return Item.query(on: req).filter(\.type == type).range(offset..<(offset+limit)).sort(sortByVar, sortingType).all()
    }
}
