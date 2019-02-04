import FluentSQLite
import Vapor

struct MealDate: Codable {
    let year: Int
    let month: Int
    let day: Int

    var fullDate: String {
        return String(format: "%04d%02d%02d", year, month, day)
    }

    var icsDate: String {
        return "DATE:\(fullDate)"
    }

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(date: Date) {
        self.year = Calendar.current.component(.year, from: date)
        self.month = Calendar.current.component(.month, from: date)
        self.day = Calendar.current.component(.day, from: date)
    }
}

/// A single entry of a Meal list.
final class Meal: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String
    var priceInCent: Int

    var allergicNotes: String?
    var vegetarian: Bool

    var date: MealDate

    /// Creates a new `Meal`.
    init(id: Int? = nil, title: String, priceInCent: Int, allergicNotes: String?, vegetarian: Bool, date: MealDate) {
        self.id = id ?? Int((vegetarian ? "1" : "0") + date.fullDate)

        self.title = title
        self.priceInCent = priceInCent

        self.allergicNotes = allergicNotes
        self.vegetarian = vegetarian

        self.date = date
    }

    convenience init?(rawTitle: String, rawPrice: String, vegetarian: Bool, date: MealDate) {
        let splitTitle = rawTitle.components(separatedBy: " (")

        let title = splitTitle[0]
        var allergicNotes = splitTitle.count > 1 ? splitTitle[1] : nil
        allergicNotes?.removeLast()

        guard let price = Int(rawPrice.replacingOccurrences(of: " Eur", with: "").replacingOccurrences(of: ",", with: "")) else {
            return nil
        }

        self.init(id: nil, title: title, priceInCent: price, allergicNotes: allergicNotes, vegetarian: vegetarian, date: date)
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

        vEvent += "UID:\(eventID)\n"
        vEvent += "DTSTAMP:\(now)\n"
        vEvent += "DTSTART;VALUE=\(date.icsDate)\n"
        vEvent += "SUMMARY:\(title)\n"

        vEvent += "DESCRIPTION:Preis:\t\t\t\(String(format: "%.2f", Float(priceInCent) / 100.0))€\n"
        if let notes = allergicNotes {
            vEvent += "  \\nAllergikerinfo:\t\t\(notes)\n"
        }
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
