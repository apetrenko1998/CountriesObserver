// @generated
// This file was automatically generated and can be edited to
// provide custom configuration for a generated GraphQL schema.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

nonisolated public enum SchemaConfiguration: ApolloAPI.SchemaConfiguration {
  public static func cacheKeyInfo(for type: ApolloAPI.Object, object: ApolloAPI.ObjectData) -> CacheKeyInfo? {
    switch type {
    case Objects.Country:
      // Countries are uniquely identified by their ISO code, so list and detail
      // responses share one normalized cache entry.
      return try? CacheKeyInfo(jsonValue: object["code"])
    default:
      return nil
    }
  }
}
