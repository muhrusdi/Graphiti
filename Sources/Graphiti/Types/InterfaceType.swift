import GraphQL

public typealias ResolveType<Value> = (
    _ value: Value,
    _ context: Any,
    _ info: GraphQLResolveInfo
) throws -> TypeResolveResultRepresentable


public final class InterfaceTypeBuilder<Type> : FieldBuilder<Type> {
    public var description: String? = nil
    var resolveType: GraphQLTypeResolve? = nil

    public func resolveType(_ resolve: @escaping ResolveType<Type>) {
        self.resolveType = { value, context, info in
            guard let v = value as? Type else {
                throw GraphQLError(message: "Expected type \(Type.self) but got \(type(of: value))")
            }

            return try resolve(v, context, info)
        }
    }
}

public struct InterfaceType<Type> {
    let interfaceType: GraphQLInterfaceType

    @discardableResult
    public init(name: String, build: (InterfaceTypeBuilder<Type>) throws -> Void) throws {
        let builder = InterfaceTypeBuilder<Type>()
        try build(builder)

        interfaceType = try GraphQLInterfaceType(
            name: name,
            description: builder.description,
            fields: builder.fields,
            resolveType: builder.resolveType
        )
        
        link(Type.self, to: interfaceType)
    }
}
