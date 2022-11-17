import SwiftUI

struct AlertViewModifier<Actions>: ViewModifier {
    let title: String
    let isPresented: Binding<Bool>
    @ViewBuilder let actions: () -> TupleView<Actions>

    func body(content: Content) -> some View {
        ZStack {
            content

            AlertView(
                title: title,
                isPresented: isPresented,
                actions: actions
            )
        }
    }
}
