import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let mealController = MealController()
    router.get("meals", use: mealController.index)
    router.get("meals.ics", use: mealController.icsIndex)
}
