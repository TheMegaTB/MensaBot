import Vapor

let icsHeader = """
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Nordakadmie Mensa//NONSGML Event Calendar//DE


"""
let icsFooter = "\nEND:VCALENDAR"

/// Controls basic CRUD operations on `Meal`s.
final class MealController {
    /// Returns a list of all `Meal`s.
    func index(_ req: Request) throws -> Future<[Meal]> {
        return Meal.query(on: req).all()
    }

    func icsIndex(_ req: Request) throws -> Future<String> {
        return Meal.query(on: req).all()
            .map(to: String.self) { meals in
                return meals.reduce(icsHeader) { $0 + $1.toICSEvent() } + icsFooter
            }
    }

    /// Saves a decoded `Meal` to the database.
    func create(_ req: Request) throws -> Future<Meal> {
        return Meal(id: nil, title: "Test", priceInCent: 350, allergicNotes: "a, b, c, Weizen", vegetarian: false, date: MealDate(year: 2018, month: 8, day: 8), sequenceID: nil).create(on: req)

//        return try req.content.decode(Meal.self).flatMap { meal in
//            return meal.save(on: req)
//        }
    }

    /// Deletes a parameterized `Meal`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Meal.self).flatMap { meal in
            return meal.delete(on: req)
        }.transform(to: .ok)
    }
}
