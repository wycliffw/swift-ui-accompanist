import AccompanistCore
import SwiftUI

extension Accompanist where Content: View {
    @ViewBuilder public func alert<Actions>(
        _ title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> TupleView<Actions>
    ) -> some View {
        let alertViewModifier = AlertViewModifier(
            title: title,
            isPresented: isPresented,
            actions: actions
        )

        content.modifier(alertViewModifier)
    }
}
