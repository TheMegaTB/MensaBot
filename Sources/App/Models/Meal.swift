import FluentSQLite
import Vapor

struct MealDate: Codable {
    let year: String
    let month: String
    let day: String

    var fullDate: String {
        return "DATE:\(year)\(month)\(day)"
    }

    init(year: String, month: String, day: String) {
        self.year = year
        self.month = month
        self.day = day
    }
}

/// A single entry of a Meal list.
final class Meal: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String
    var priceInCent: Int

    var allergicContents: String
    var vegetarian: Bool

    var date: MealDate

    /// Creates a new `Meal`.
    init(id: Int? = nil, title: String, priceInCent: Int, allergicContents: String, vegetarian: Bool, date: MealDate) {
        self.id = id

        self.title = title
        self.priceInCent = priceInCent

        self.allergicContents = allergicContents
        self.vegetarian = vegetarian

        self.date = date
    }
}

/// Allows `Meal` to be used as a dynamic migration.
extension Meal: Migration { }

/// Allows `Meal` to be encoded to and decoded from HTTP messages.
extension Meal: Content { }

/// Allows `Meal` to be used as a dynamic parameter in route definitions.
extension Meal: Parameter { }
