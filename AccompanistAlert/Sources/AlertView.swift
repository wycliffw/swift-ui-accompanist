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
                actions: actions
            )
            
            DispatchQueue.main.async {
                uiViewController.present(alertController, animated: true, completion: {
                    self.isPresented.wrappedValue.toggle()
                })
            }
        }
    }
}
