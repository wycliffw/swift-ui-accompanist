import Combine
import SwiftUI

struct UIAlertControllerFactory {
    static func create<Actions>(
        title: String,
        message: String?,
        actions: () -> TupleView<Actions>,
        onDismiss: @escaping () -> ()
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let actions: [Any] = {
            let actions = actions() // Gets us TupleView
            let actionsReflection = Mirror(reflecting: actions.value)

            return actionsReflection.children.map { $0.value } // Returning items of TupleView as an array
        }()

        for action in actions {
            // We are checking the actions supplied to us so we can correctly add those
            // that are supported to the alert controller
            if let button = action as? Button<Text> {
                let alertAction = makeUIAlertAction(button: button, onDismiss: onDismiss)

                alertController.addAction(alertAction)
            } else if let textField = action as? TextField<Text> {
                let children = Mirror(reflecting: textField).children

                let text  = children.first(where: { $0.label == "_text" })?.value as? Binding<String>
                let label = children.first(where: { $0.label == "label" })?.value as? Text

                alertController.addTextField { textField in
                    textField.text = text?.wrappedValue ?? ""
                    textField.placeholder = getString(text: label!) ?? ""

                    let cancellable = NotificationCenter.default
                        .publisher(for: UITextField.textDidChangeNotification, object: textField)
                        .map { ($0.object as? UITextField)?.text }
                        .sink { value in
                            if let text = text, let value = value {
                                text.wrappedValue = value
                            }
                        }

                    objc_setAssociatedObject(textField, "\(UUID())", cancellable, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                }
            } else if let modifiedContent = action as? ModifiedContent<Button<Text>, _EnvironmentKeyTransformModifier<Bool>> {
                let alertAction = makeUIAlertAction(button: modifiedContent.content, onDismiss: onDismiss)

                let children = Mirror(reflecting: modifiedContent.modifier).children

                let keyPath   = children.first { $0.label == "keyPath"   }!.value as! WritableKeyPath<EnvironmentValues, Bool>
                let transform = children.first { $0.label == "transform" }!.value as! (inout Bool) -> ()

                if keyPath == \.isEnabled {
                    transform(&alertAction.isEnabled)
                }

                alertController.addAction(alertAction)
            } else {
                print(type(of: action))
            }
        }

        if alertController.actions.count == 0 {
            // If no action was added to the alert controller, we add an OK default action
            let alertAction = UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default,
                handler: { _ in
                    onDismiss()
                }
            )
            alertController.addAction(alertAction)
        }

        return alertController
    }

    static private func makeUIAlertAction(button: Button<Text>, onDismiss: @escaping () -> ()) -> UIAlertAction {
        let children = Mirror(reflecting: button).children
        let role   = children.first { $0.label == "role"   }?.value as? ButtonRole
        let action = children.first { $0.label == "action" }?.value as? () -> ()
        let label  = children.first { $0.label == "label"  }?.value as? Text

        var actionStyle: UIAlertAction.Style = .default
        switch role {
            case ButtonRole.cancel:
                actionStyle = .cancel
            case ButtonRole.destructive:
                actionStyle = .destructive
            default:
                actionStyle = .default
        }

        return UIAlertAction(
            title: getString(text: label!) ?? "",
            style: actionStyle,
            handler: { _ in
                action?()

                onDismiss()
            }
        )
    }

    static private func getString(key: LocalizedStringKey, table: String? = nil, bundle: String? = nil) -> String? {
        let keyReflection = Mirror(reflecting: key)
        let key = keyReflection.children.first(where: { $0.label == "key" })?.value as? String

        return (bundle != nil ? Bundle(identifier: bundle!) : Bundle.main)?.localizedString(
            forKey: key ?? "",
            value: nil,
            table: table
        )
    }

    static private func getString(text: Text) -> String? {
        let textReflection = Mirror(reflecting: text)

        if let storage = textReflection.children.first(where: { $0.label == "storage" })?.value {
            let storageReflection = Mirror(reflecting: storage)

            if let anyTextStorage = storageReflection.children.first(where: { $0.label == "anyTextStorage" })?.value {
                let anyTextStorageReflexion = Mirror(reflecting: anyTextStorage)

                let key    = anyTextStorageReflexion.children.first(where: { $0.label == "key"    })?.value as? LocalizedStringKey
                let table  = anyTextStorageReflexion.children.first(where: { $0.label == "table"  })?.value as? String
                let bundle = anyTextStorageReflexion.children.first(where: { $0.label == "bundle" })?.value as? String

                return getString(key: key!, table: table, bundle: bundle)
            }
        }
        
        return nil
    }
}
