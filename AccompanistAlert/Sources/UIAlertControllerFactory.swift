import SwiftUI

struct UIAlertControllerFactory {
    static func create<Actions>(
        title: String,
        message: String?,
        actions: () -> TupleView<Actions>
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        // TODO: Add textfields, actions, etc. to the alert controller based on the provided actions TupleView
        let alertAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "Default action"),
            style: .default,
            handler: { _ in }
        )
        alertController.addAction(alertAction)

        return alertController
    }
}
