import Vapor

/// Controls basic CRUD operations on `Meal`s.
final class MealController {
    /// Returns a list of all `Meal`s.
    func index(_ req: Request) throws -> Future<[Meal]> {
        return Meal.query(on: req).all()
    }

    /// Saves a decoded `Meal` to the database.
//    func create(_ req: Request) throws -> Future<Meal> {
//        return try req.content.decode(Meal.self).flatMap { todo in
//            return todo.save(on: req)
//        }
//    }

    /// Deletes a parameterized `Meal`.
//    func delete(_ req: Request) throws -> Future<HTTPStatus> {
//        return try req.parameters.next(Meal.self).flatMap { todo in
//            return todo.delete(on: req)
//        }.transform(to: .ok)
//    }
}
