// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI
import CountriesAPI

nonisolated struct CountryDetailsQuery: GraphQLQuery {
  static let operationName: String = "CountryDetails"
  static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CountryDetails($code: ID!) { country(code: $code) { __typename ...CountrySummary capital currency languages { __typename name } } }"#,
      fragments: [CountrySummary.self]
    ))

  public var code: CountriesAPI.ID

  public init(code: CountriesAPI.ID) {
    self.code = code
  }

  @_spi(Unsafe) public var __variables: Variables? { ["code": code] }

  nonisolated struct Data: CountriesAPI.SelectionSet {
    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Query }
    static var __selections: [ApolloAPI.Selection] { [
      .field("country", Country?.self, arguments: ["code": .variable("code")]),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CountryDetailsQuery.Data.self
    ] }

    var country: Country? { __data["country"] }

    init(
      country: Country? = nil
    ) {
      self.init(unsafelyWithData: [
        "__typename": CountriesAPI.Objects.Query.typename,
        "country": country._fieldData,
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
        .field("capital", String?.self),
        .field("currency", String?.self),
        .field("languages", [Language].self),
        .fragment(CountrySummary.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CountryDetailsQuery.Data.Country.self,
        CountrySummary.self
      ] }

      var capital: String? { __data["capital"] }
      var currency: String? { __data["currency"] }
      var languages: [Language] { __data["languages"] }
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
        capital: String? = nil,
        currency: String? = nil,
        languages: [Language],
        code: CountriesAPI.ID,
        name: String,
        emoji: String,
        continent: Continent
      ) {
        self.init(unsafelyWithData: [
          "__typename": CountriesAPI.Objects.Country.typename,
          "capital": capital,
          "currency": currency,
          "languages": languages._fieldData,
          "code": code,
          "name": name,
          "emoji": emoji,
          "continent": continent._fieldData,
        ])
      }

      /// Country.Language
      ///
      /// Parent Type: `Language`
      nonisolated struct Language: CountriesAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { CountriesAPI.Objects.Language }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CountryDetailsQuery.Data.Country.Language.self
        ] }

        var name: String { __data["name"] }

        init(
          name: String
        ) {
          self.init(unsafelyWithData: [
            "__typename": CountriesAPI.Objects.Language.typename,
            "name": name,
          ])
        }
      }

      typealias Continent = CountrySummary.Continent
    }
  }
}
