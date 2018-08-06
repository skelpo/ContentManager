import FluentMySQL
import Vapor


final class Item: Content, MySQLModel, Migration, Parameter {
    static let entity: String = "items"
    /// The unique identifier for this `Item`.
    var id: Int?

   
    var title: String?
    var slug: String?
    
    var body: String?
    var type: String
    
    var language: String?
    
    var deletedAt: Date?
    var createdAt: Date?
    var publishedAt: Date?
    
    var userId: Int

    /// Creates a new `Item`.
    init(_ title: String, type: String, userId: Int) {
        self.title = title
        self.userId = userId
        self.type = type
    }
    
    /// Create a query that gets all the attributes belonging to a user.
    func media(on connection: DatabaseConnectable) -> QueryBuilder<Media.Database, Media> {
        // Return an `Attribute` query that filters on the `userId` field.
        return Media.query(on: connection).filter(\.itemId == self.id!)
    }
}
