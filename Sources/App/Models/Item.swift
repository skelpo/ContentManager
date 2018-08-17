import FluentMySQL
import Vapor
import Fluent


final class Item: Content, MySQLModel, Migration, Parameter {
    static let entity: String = "items"
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
    
    /// The unique identifier for this `Item`.
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

    /// Creates a new `Item`.
    init(_ title: String, type: String, userId: Int) {
        self.title = title
        self.userId = userId
        self.type = type
    }
}
