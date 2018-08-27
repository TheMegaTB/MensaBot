import Vapor

func updateData(_ app: Application, baseDate: Date) throws {
    let client = try app.client()
    let weekday = Calendar.current.component(.weekday, from: baseDate)
    let startDate = Calendar.current.date(byAdding: .day, value: -(weekday - 2), to: baseDate)!

    let timestamp = Int(baseDate.timeIntervalSince1970 * 1000)

    _ = client.crawlMensa(url: "https://cis.nordakademie.de/mensa/speiseplan.cmd?date=\(timestamp)&action=show") { data in

        let days = zip(data.readableTitles, data.readablePrices).map { day in
            zip(day.0, day.1)
        }

        days.enumerated().forEach { index, day in
            day.enumerated().forEach { dayIndex, meal in
                guard let mealDate = Calendar.current.date(byAdding: .day, value: index, to: startDate) else {
                    return
                }
                let fallbackDate = MealDate(date: mealDate)
                let date = data.dates[dayIndex] ?? fallbackDate

                guard let meal = Meal.init(rawTitle: meal.0, rawPrice: meal.1, vegetarian: dayIndex == 1, date: date) else {
                    return
                }

                _ = app.withNewConnection(to: .sqlite) { conn in
                    return meal.create(on: conn)
                }
            }
        }
    }
}

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    DispatchQueue.global().async {
        while true {
//            _ = try? updateData(app, baseDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
            _ = try? updateData(app, baseDate: Date())
//            _ = try? updateData(app, baseDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
            Thread.sleep(forTimeInterval: 60 * 60 * 24)
        }
    }
}

extension Client {
    func crawlMensa(url: String, callback: @escaping (MensaHTMLDecoder) -> Void) -> EventLoopFuture<Response> {
        return get(url).do { response in
            guard let data = response.http.body.data, let content = String(data: data, encoding: .utf8) else {
                return
            }

            // Find and remove invalid xml.
            guard let regex = try? NSRegularExpression(pattern: "<(meta|img|br|hr).*?>", options: []) else {
                return
            }

            let contentWithoutJS = regex.stringByReplacingMatches(
                in: content,
                options: [],
                range: NSRange(location: 0, length: NSString(string: content).length),
                withTemplate: "")
                .replacingOccurrences(of: "&action", with: "action")

            let decoder = MensaHTMLDecoder()
            let parser = XMLParser(data: contentWithoutJS.data(using: .utf8)!)
            parser.delegate = decoder
            parser.shouldProcessNamespaces = true
            parser.parse()

            callback(decoder)
        }
    }
}

class MensaHTMLDecoder: NSObject, XMLParserDelegate {
    private var contentType = ContentType.none
    private var day = -1
    private(set) var dates: [MealDate?] = []
    private var titles: [[[String]]] = Array(repeating: [], count: 5)
    private(set) var prices: [[[String]]] = Array(repeating: [], count: 5)

    var readableTitles: [[String]] {
        return titles.map {
            $0.map {
                $0.joined().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
    }

    var readablePrices: [[String]] {
        return prices.map {
            $0.map {
                $0.joined().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
    }

    private enum ContentType {
        case none
        case title
        case price
        case date
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "table" && attributeDict["class"] == "speiseplan-tag" {
            day += 1
        } else if elementName == "div" {
            if attributeDict["class"] == "speiseplan-kurzbeschreibung " {
                contentType = .title
                titles[day].append([])
            } else if attributeDict["class"] == "speiseplan-preis" {
                contentType = .price
                prices[day].append([])
            }
        } else if elementName == "td" {
            if attributeDict["class"] == "speiseplan-head" {
                contentType = .date
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName != "b" {
            contentType = .none
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch contentType {
        case .none:
            break
        case .title:
            titles[day][titles[day].count - 1].append(string)
        case .price:
            prices[day][prices[day].count - 1].append(string)
        case .date:
            if string.contains(".") {
                let currentYear = Calendar.current.component(.year, from: Date())
                let dateComponents = string.split(separator: "\n")[1]
                                    .trimmingCharacters(in: [" "])
                                    .split(separator: ".")

                if let month = Int(dateComponents[1]), let day = Int(dateComponents[0]) {
                    dates.append(MealDate(year: currentYear, month: month, day: day))
                } else {
                    print("Failed to parse date!")
                    dates.append(nil)
                }
            }
        }


    }
}
