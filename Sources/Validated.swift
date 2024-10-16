import SwiftUI

// MARK: - Validated

/// A Validated PropertyWrapper
@propertyWrapper
public struct Validated<Value>: Validatable, DynamicProperty {
    
    // MARK: Properties
    
    /// The Validation
    public var validation: Validation<Value> {
        didSet {
            // Re-Validate
            self.isValid = self.validation.validate(self.value)
        }
    }
    
    /// The Value
    @State
    private var value: Value
    
    /// Bool value if the value has been modified
    @State
    public private(set) var hasChanges = false
    
    /// Bool value if validated value is valid
    @State
    public private(set) var isValid: Bool
    
    // MARK: PropertyWrapper-Properties
    
    /// The underlying value referenced by the Validated variable
    public var wrappedValue: Value {
        get {
            self.projectedValue.wrappedValue
        }
        nonmutating set {
            self.projectedValue.wrappedValue = newValue
        }
    }
    
    /// A binding to the Validated value
    public var projectedValue: Binding<Value> {
        .init(
            get: {
                self.value
            },
            set: { newValue in
                self.value = newValue
                if !self.hasChanges {
                    self.hasChanges.toggle()
                }
                self.isValid = self.validation.validate(newValue)
            }
        )
    }
    
    /// The error message associated with the validation failure.
    /// This property is read-only outside of the struct/class but can be set privately within.
    /// Default value is `nil`.
    public private(set) var errorMessage: String?
    
    // MARK: Initializer
    
    /// Creates a new instance of `Validated`
    /// - Parameters:
    ///   - wrappedValue: The wrapped `Value`
    ///   - validation: The `Validation`
    public init(
        wrappedValue: Value,
        _ validation: Validation<Value>
    ) {
        self.validation = validation
        self._value = .init(
            initialValue: wrappedValue
        )
        self._isValid = .init(
            initialValue: validation
                .validate(wrappedValue)
        )
    }
    
    
    /// Creates a new instance of `Validated`
    /// - Parameters:
    ///   - wrappedValue: The wrapped `Value`
    ///   - validation: The `Validation`
    ///   - errorMessage: A custom error message when validation fails
    public init(
        wrappedValue: Value,
        _ validation: Validation<Value>,
        errorMessage: String
    ) {
        self.init(wrappedValue: wrappedValue, validation)
        self.errorMessage = errorMessage
    }
    
    /// Creates a new instance of `Validated`
    /// - Parameters:
    ///   - wrappedValue: The  `WrappedValue`. Default value `nil`
    ///   - validation: The `Validation`
    ///   - isNilValid: A closure that returns a Boolean value if `nil` should be treated as valid or not. Default value `false`
    public init<WrappedValue>(
        wrappedValue: WrappedValue? = nil,
        _ validation: Validation<WrappedValue>,
        isNilValid: @autoclosure @escaping () -> Bool = false
    ) where WrappedValue? == Value {
        self.init(
            wrappedValue: wrappedValue,
            .init(
                validation,
                isNilValid: isNilValid()
            )
        )
    }
    
    /// Creates a new instance of `Validated` for optional values with a custom error message
    /// - Parameters:
    ///   - wrappedValue: The optional `WrappedValue`. Default value `nil`
    ///   - validation: The `Validation`
    ///   - errorMessage: A custom error message when validation fails
    ///   - isNilValid: A closure that returns a Boolean value indicating if `nil` should be considered valid. Default value `false`
    public init<WrappedValue>(
        wrappedValue: WrappedValue? = nil,
        _ validation: Validation<WrappedValue>,
        errorMessage: String,
        isNilValid: @autoclosure @escaping () -> Bool = false
    ) where WrappedValue? == Value {
        self.init(
            wrappedValue: wrappedValue,
            .init(
                validation,
                isNilValid: isNilValid()
            )
        )
        self.errorMessage = errorMessage
    }
}

// MARK: - Validated+validatedValue

public extension Validated {
    
    /// The value if is valid otherwise returns `nil`
    var validatedValue: Value? {
        self.isValid ? self.value : nil
    }
    
}

// MARK: - Validated+isInvalid

public extension Validated {
    
    /// A Boolean value if the value is invalid
    var isInvalid: Bool {
        !self.isValid
    }
    
}

// MARK: - Validated+isInvalidAfterChanges

public extension Validated {
    
    /// A Boolean value if the value is invalid and has been previously modified
    var isInvalidAfterChanges: Bool {
        self.hasChanges && !self.isValid
    }
    
}
