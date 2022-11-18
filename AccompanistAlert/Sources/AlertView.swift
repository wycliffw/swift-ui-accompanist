import SwiftUI

struct AlertView<Actions>: UIViewControllerRepresentable {
    let title: String
    let message: String? = nil
    let isPresented: Binding<Bool>
    @ViewBuilder let actions: () -> TupleView<Actions>

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented.wrappedValue {
            let alertController = UIAlertControllerFactory.create(
                title: title,
                message: nil,
                actions: actions,
                onDismiss: {
                    self.isPresented.wrappedValue.toggle()
                }
            )

            if let oldAlertController = uiViewController.presentedViewController as? UIAlertController {
                // We don't want to dismiss the already presented alert so we update old alert
                oldAlertController.title = alertController.title
                oldAlertController.message = alertController.message

                for (index, action) in alertController.actions.enumerated() {
                    oldAlertController.actions[index].isEnabled = action.isEnabled
                }
            } else {
                DispatchQueue.main.async {
                    uiViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
