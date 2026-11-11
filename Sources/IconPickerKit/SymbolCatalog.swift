/// Curated SF Symbol names used by ``IconPickerView``, in catalog order.
public enum SymbolCatalog {
    public static let ids: [String] = IconGroup.allCases.flatMap { IconCatalog.content(for: $0).1 }
}
