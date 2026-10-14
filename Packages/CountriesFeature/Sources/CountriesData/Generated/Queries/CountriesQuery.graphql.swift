// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI
import CountriesAPI

nonisolated struct CountriesQuery: GraphQLQuery {
  static let operationName: String = "Countries"
  static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Countries($filter: CountryFilterInput) { countries(filter: $filter) { __typename ...CountrySummary } }"#,
      fragments: [CountrySummary.self]
    ))

  public var filter: GraphQLNullable<CountriesAPI.CountryFilterInput>

  public init(filter: GraphQLNullable<CountriesAPI.CountryFilterInput>) {
    self.filter = filter
  }

  @_spi(Unsafe) public var __variables: Variables? { ["filter": filter] }

  nonisolated struct Data: CountriesAPI.SelectionSet {
    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Query }
    static var __selections: [ApolloAPI.Selection] { [
      .field("countries", [Country].self, arguments: ["filter": .variable("filter")]),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CountriesQuery.Data.self
    ] }

    var countries: [Country] { __data["countries"] }

    init(
      countries: [Country]
    ) {
      self.init(unsafelyWithData: [
        "__typename": CountriesAPI.Objects.Query.typename,
        "countries": countries._fieldData,
      ])
    }

    /// Country
    ///
    /// Parent Type: `Country`
    nonisolated struct Country: CountriesAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Country }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(CountrySummary.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CountriesQuery.Data.Country.self,
        CountrySummary.self
      ] }

      var code: CountriesAPI.ID { __data["code"] }
      var name: String { __data["name"] }
      var emoji: String { __data["emoji"] }
      var continent: Continent { __data["continent"] }

      struct Fragments: FragmentContainer {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        var countrySummary: CountrySummary { _toFragment() }
      }

      init(
        code: CountriesAPI.ID,
        name: String,
        emoji: String,
        continent: Continent
      ) {
        self.init(unsafelyWithData: [
          "__typename": CountriesAPI.Objects.Country.typename,
          "code": code,
          "name": name,
          "emoji": emoji,
          "continent": continent._fieldData,
        ])
      }

      typealias Continent = CountrySummary.Continent
    }
  }
}
