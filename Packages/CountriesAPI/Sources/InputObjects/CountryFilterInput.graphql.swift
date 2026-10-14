// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

nonisolated public struct CountryFilterInput: InputObject {
  @_spi(Unsafe) public private(set) var __data: InputDict

  @_spi(Unsafe) public init(_ data: InputDict) {
    __data = data
  }

  public init(
    code: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> = nil,
    continent: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> = nil,
    currency: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> = nil,
    name: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> = nil
  ) {
    __data = InputDict([
      "code": code,
      "continent": continent,
      "currency": currency,
      "name": name
    ])
  }

  public var code: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> {
    get { __data["code"] }
    set { __data["code"] = newValue }
  }

  public var continent: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> {
    get { __data["continent"] }
    set { __data["continent"] = newValue }
  }

  public var currency: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> {
    get { __data["currency"] }
    set { __data["currency"] = newValue }
  }

  public var name: GraphQLNullable<CountriesAPI.StringQueryOperatorInput> {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }
}
