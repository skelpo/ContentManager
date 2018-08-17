import Vapor
import Fluent
import FluentMySQL

struct ItemInput: Content {
    var id: Int?
    
    var title: String
    var slug: String?
    
    var body: String?
    var type: String
    
    var language: String?
    
    var publishedAt: Date?
    
    /// Creates a new `Item`.
    init(_ title: String, type: String) {
        self.title = title
        self.type = type
    }
    
    func makeClass(userId: Int) -> Item {
        let item = Item(self.title, type: self.type, userId: userId)
        item.slug = self.slug
        item.body = self.body
        item.language = self.language
        item.publishedAt = self.publishedAt
        return item
    }
}

struct ItemUpdate: Content {
    var id: Int
    var title: String?
    var slug: String?
    var body: String?
    var language: String?
    var publishedAt: Date?
}

struct MediaAttachmentInput: Content {
    var contentId: Int
    var mediaUrl: String
}

struct ItemOutput: Content {
    var id: Int?
    var title: String?
    var slug: String?
    var body: String?
    var type: String
    var language: String?
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var publishedAt: Date?
    var userId: Int
    var media:[Media] = []
    
    init(_ item: Item) {
        self.id = item.id
        self.title = item.title
        self.body = item.body
        self.userId = item.userId
        self.type = item.type
        self.slug = item.slug
        self.language = item.language
        self.deletedAt = item.deletedAt
        self.createdAt = item.createdAt
        self.updatedAt = item.updatedAt
        self.publishedAt = item.publishedAt
    }
}

final class ContentController: RouteCollection {
    
    func boot(router: Router) {
        router.get(String.parameter, use: index)
        router.get("byId", String.parameter, use: byId)
        router.post(ItemInput.self, at: "item", use: createItem)
        router.post(MediaAttachmentInput.self, at: "attach", use: attachMedia)
        router.patch(ItemUpdate.self, at: "item", use: updateItem)
        router.delete("item", Int.parameter, use: deleteItem)
        router.delete("media", Int.parameter, use: deleteMedia)
        router.get("item", Int.parameter, use: getItem)
    }
    
    func output(_ item: Item, _ req: Request) throws -> Future<ItemOutput> {
        var out = ItemOutput(item)
        return Media.query(on: req).filter(\.itemId == item.id!).all().map(to: ItemOutput.self) { media in
            out.media = media
            return out
        }
    }
    
    func createItem(_ req: Request, item: ItemInput) throws -> Future<ItemOutput> {
        return item.makeClass(userId: 1).create(on: req).flatMap(to: ItemOutput.self) { item in
            return try self.output(item, req)
        }
    }
    func attachMedia(_ req: Request, input: MediaAttachmentInput) throws -> Future<Media> {
        return Item.find(input.contentId, on: req).flatMap(to: Media.self) { item in
            if item == nil {
                throw Abort(.badRequest, reason: "No model with id \(input.contentId) found")
            }
            let media = Media(itemId: item!.id!)
            media.url = input.mediaUrl
            return media.create(on: req)
        }
        
    }
    func deleteMedia(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let id = try req.parameters.next(Int.self)
        return Media.find(id, on: req).flatMap(to: HTTPResponseStatus.self) { media in
            if media == nil {
                throw Abort(.badRequest, reason: "No media with id \(id) found")
            }
            return media!.delete(on: req).map(to: HTTPResponseStatus.self) { _ in
                return HTTPStatus.ok
            }
        }
    }
    
    func deleteItem(_ req: Request) throws -> Future<HTTPResponseStatus> {
        let id = try req.parameters.next(Int.self)
        return Item.find(id, on: req).flatMap(to: HTTPResponseStatus.self) { item in
            if item == nil {
                throw Abort(.badRequest, reason: "No model with id \(id) found")
            }
            return item!.delete(on: req).map(to: HTTPResponseStatus.self) { _ in
                return HTTPStatus.ok
            }
        }
    }
    
    func updateItem(_ req: Request, itemUpdate: ItemUpdate) throws -> Future<ItemOutput> {
        return Item.find(itemUpdate.id, on: req).flatMap(to: ItemOutput.self) { item in
            if item == nil {
                throw Abort(.badRequest, reason: "No model with id \(itemUpdate.id) found")
            }
            if let title = itemUpdate.title {
                item!.title = title
            }
            if let slug = itemUpdate.slug {
                item!.slug = slug
            }
            if let body = itemUpdate.body {
                item!.body = body
            }
            if let language = itemUpdate.language {
                item!.language = language
            }
            if let publishedAt = itemUpdate.publishedAt {
                item!.publishedAt = publishedAt
            }
            return item!.save(on: req).flatMap(to: ItemOutput.self) { item in
                return try self.output(item, req)
            }
        }
    }
    
    func byId(_ req: Request) throws -> Future<[ItemOutput]> {
        let type = try req.parameters.next(String.self)
        var ids_ = ""
        
        do {
            ids_ = try req.query.get(String.self, at: "ids")
        }
        catch {}
        
        let idsString = ids_.split(separator: ",")
        let ids = idsString.map { Int($0) ?? 0 }
        return Item.query(on: req).filter(\.type == type).filter(\.id ~~ ids).all().flatMap(to: [ItemOutput].self) { items in
            return try items.map { try self.output($0, req) }.flatten(on: req)
        }
    }
    
    func getItem(_ req: Request) throws -> Future<ItemOutput> {
        let id = try req.parameters.next(Int.self)
        return Item.find(id, on: req).flatMap(to: ItemOutput.self) { item in
            if item == nil {
                throw Abort(.badRequest, reason: "No model with id \(id) found")
            }
            return try self.output(item!, req)
        }
    }

    func index(_ req: Request) throws -> Future<[ItemOutput]> {
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
        var query = Item.query(on: req).filter(\.type == type).range(offset..<(offset+limit))
        
        switch sortBy {
        case "userId":
            query = query.sort(\Item.userId, sortingType)
            break
        case "title":
            query = query.sort(\Item.title, sortingType)
            break
        default:
            query = query.sort(\Item.publishedAt, sortingType)
        }
        return query.all().flatMap(to: [ItemOutput].self) { items in
            return try items.map { try self.output($0, req) }.flatten(on: req)
        }
    }
}
