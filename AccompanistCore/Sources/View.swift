import SwiftUI

extension View {
    public var accompanist: Accompanist<Self> {
        Accompanist(content: self)
    }
}
