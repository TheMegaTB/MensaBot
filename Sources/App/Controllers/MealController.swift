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
        let sortVegeterian = try? req.query.get(Int.self, at: "sortVegeterian")
        let filterVegeterian = try? req.query.get(Int.self, at: "filterVegeterian")

        return Meal.query(on: req).all()
            .map(to: String.self) { meals in
                var meals = meals
                if filterVegeterian == 0 {
                    meals = meals.filter { !$0.vegetarian }
                } else if filterVegeterian == 1 {
                    meals = meals.filter { $0.vegetarian }
                } else if sortVegeterian == 0 {
                    meals = meals.sorted { meal, _ in !meal.vegetarian }
                } else if sortVegeterian == 1 {
                    meals = meals.sorted { meal, _ in meal.vegetarian }
                }
                return meals.reduce(icsHeader) { $0 + $1.toICSEvent() } + icsFooter
            }
    }
}
