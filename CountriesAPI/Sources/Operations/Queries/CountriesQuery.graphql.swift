// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct CountriesQuery: GraphQLQuery {
  public static let operationName: String = "Countries"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Countries { countries { __typename code name emoji capital currency continent { __typename name } } }"#
    ))

  public init() {}

  nonisolated public struct Data: CountriesAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("countries", [Country].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CountriesQuery.Data.self
    ] }

    public var countries: [Country] { __data["countries"] }

    /// Country
    ///
    /// Parent Type: `Country`
    nonisolated public struct Country: CountriesAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Country }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("code", CountriesAPI.ID.self),
        .field("name", String.self),
        .field("emoji", String.self),
        .field("capital", String?.self),
        .field("currency", String?.self),
        .field("continent", Continent.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CountriesQuery.Data.Country.self
      ] }

      public var code: CountriesAPI.ID { __data["code"] }
      public var name: String { __data["name"] }
      public var emoji: String { __data["emoji"] }
      public var capital: String? { __data["capital"] }
      public var currency: String? { __data["currency"] }
      public var continent: Continent { __data["continent"] }

      /// Country.Continent
      ///
      /// Parent Type: `Continent`
      nonisolated public struct Continent: CountriesAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Continent }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CountriesQuery.Data.Country.Continent.self
        ] }

        public var name: String { __data["name"] }
      }
    }
  }
}
