import FluentSQLite
import Vapor

struct MealDate: Codable {
    let year: Int
    let month: Int
    let day: Int

    var fullDate: String {
        return String(format: "DATE:%04d%02d%02d", year, month, day)
    }

    init(year: Int, month: Int, day: Int) {
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

    var allergicNotes: String
    var vegetarian: Bool

    var date: MealDate
    var sequenceID: Int

    /// Creates a new `Meal`.
    init(id: Int? = nil, title: String, priceInCent: Int, allergicNotes: String, vegetarian: Bool, date: MealDate, sequenceID: Int?) {
        self.id = id

        self.title = title
        self.priceInCent = priceInCent

        self.allergicNotes = allergicNotes
        self.vegetarian = vegetarian

        self.date = date
        self.sequenceID = sequenceID ?? 0
    }

    func toICSEvent() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let now = formatter.string(from: Date())
        let eventID = id.map { String($0) } ?? UUID().uuidString

        var vEvent = """
        BEGIN:VEVENT
        STATUS:CONFIRMED
        ORGANIZER;CN=Maik Kosmol:MAILTO:maik.kosmol@nordakademie.de

        """

        vEvent += "SEQUENCE:\(sequenceID)\n"
        vEvent += "UID:\(eventID)\n"
        vEvent += "DTSTAMP:\(now)\n"
        vEvent += "DTSTART;VALUE=\(date.fullDate)\n"
        vEvent += "SUMMARY:\(title)\n"

        vEvent += "DESCRIPTION:Preis:\t\t\t\(String(format: "%.2f", Float(priceInCent) / 100.0))€\n"
        vEvent += "  \\nAllergikerinfo:\t\t\(allergicNotes)\n"
        vEvent += "  \\nVegetarisch:\t\t\(vegetarian ? "Ja" : "Nein")\n"

        vEvent += "END:VEVENT\n"

        return vEvent
    }
}

/// Allows `Meal` to be used as a dynamic migration.
extension Meal: Migration { }

/// Allows `Meal` to be encoded to and decoded from HTTP messages.
extension Meal: Content { }

/// Allows `Meal` to be used as a dynamic parameter in route definitions.
extension Meal: Parameter { }
