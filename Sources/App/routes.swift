import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let mealController = MealController()
    router.get("meals", use: mealController.index)
    router.get("meals.ics", use: mealController.index)
//    router.post("meals", use: mealController.create)
//    router.delete("meals", Meal.parameter, use: mealController.delete)
}
