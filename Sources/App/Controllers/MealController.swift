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
}
