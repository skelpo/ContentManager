import FluentMySQL
import Vapor

final class Media: Content, MySQLModel, Migration, Parameter {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
    static let entity: String = "media"
    
    var id: Int?
    
    var url: String?
    var path: String?
    
    var itemId: Int
    
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var publishedAt: Date?
    
    
    init(itemId: Int) {
        self.itemId = itemId
    }
}
