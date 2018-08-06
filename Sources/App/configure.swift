import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(CORSMiddleware(configuration: .default()))
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    
    guard
        let host = Environment.get("DATABASE_HOSTNAME"),
        let user = Environment.get("DATABASE_USER"),
        let name = Environment.get("DATABASE_DB")
        else {
            throw MySQLError(
                identifier: "missingEnvVars",
                reason: "One or more expected environment variables are missing: DATABASE_HOSTNAME, DATABASE_USER, DATABASE_DB"
            )
    }
    let config = MySQLDatabaseConfig(
        hostname: host,
        port: 3306,
        username: user,
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: name
    )
    let database = MySQLDatabase(config: config)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Item.self, database: .mysql)
    migrations.add(model: Media.self, database: .mysql)
    services.register(migrations)

}
