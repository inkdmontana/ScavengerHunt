

import UIKit
import CoreLocation

class Task {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Task {
    static var mockedTasks: [Task] {
        return [
            Task(title: "Find a Waterfall 💦", description: "Call Autumn"),
            Task(title: "Get a cut 💈", description: "Call Nelson"),
            Task(title: "Walk dogs 🐕‍🦺", description: "Take G & Oso to park")
        ]
    }
}
