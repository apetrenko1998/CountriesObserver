# CountriesObserver

## Requirements

| | |
|---|---|
| Xcode | 26.4 |
| iOS deployment target | 26.4 (app target), iOS 17 (local packages) |
| Developed against | iPhone 17 Pro simulator, iOS 26.4 |
| Swift | 6, strict concurrency checking (`complete`) |

## Build and run

1. Open `CountriesObserver.xcodeproj`.
2. Select the `CountriesObserver` scheme and an iOS 26.4 simulator.
3. Run with ⌘R.

Swift Package Manager resolves Apollo iOS and the SwiftLint plugin on first open.
If Xcode asks to trust the SwiftLint build tool plugin, allow it.

### Regenerating GraphQL code

Generated code is committed, so this is only needed after changing the schema or an operation.
The Apollo CLI binary is not committed. Download `apollo-ios-cli` for Apollo iOS 2.4.0 from the
[Apollo iOS releases](https://github.com/apollographql/apollo-ios/releases) into the repository root, then run:

```sh
./apollo-ios-cli fetch-schema --path apollo-codegen-config.json   # refresh GraphQL/schema.graphqls
./apollo-ios-cli generate --path apollo-codegen-config.json       # regenerate Swift code
```

## Project structure

```
CountriesObserver (app)      Entry point and composition root (AppAssembly) only
Packages/
  CountriesFeature
    CountriesDomain          Entities, repository protocol, use cases. No dependencies
    CountriesData            GraphQL operations, generated code, repository, mapping to domain
    CountriesPresentation    SwiftUI views, @Observable view models, coordinator
  Networking                 GraphQLClient protocol, Apollo-backed client, NetworkError
                             (+ NetworkingTestSupport: MockGraphQLClient for tests)
  CountriesAPI               Apollo-generated schema types
  DesignSystem               Semantic colours, stacked-layout environment value
  DependencyInjection        Small DI container
```

## Key decisions

**Layered feature: Domain, Data, Presentation.** For two screens this is more structure than the code strictly
needs, and that is deliberate. The layers show where each concern belongs and how the feature would grow:
- Domain holds the entities and the use cases.
- Data owns everything Apollo: operations, generated types, and the mapping into domain entities.
- Presentation only sees domain types.

Each layer is a separate SPM target, so the compiler enforces the boundaries instead of a code review.
`FetchCountryDetailsUseCase` is a plain pass-through today. It is kept for consistency: business rules,
such as the search-query normalisation in `FetchCountriesUseCase`, have a place to live that is neither
the view model nor the repository.

**Two test seams.** `GraphQLClient` (Networking) is the network boundary, and `CountriesRepositoryInterface`
(Domain) is the data boundary. Repository and mapping tests mock the client. View model unit tests stub use cases.
`CountriesIntegrationTests` run the view models on the real use cases and repository, with only `GraphQLClient` mocked.

**DI container and service locator in the coordinator.** The intent is to show the dependency-injection concept
end to end:
- `AppAssembly` is the single composition root that registers abstractions with their lifetimes
  (singleton `GraphQLClient` and repository, transient use cases).
- Features depend on protocols, never on concrete types.
- Tests swap registrations freely.

Dependencies are resolved from a `DependencyResolver`, so it acts as a service locator.
The trade-off is known: a missing registration fails at runtime instead of at compile time, and Presentation
depends on the DI package. This concept was selected to demonstrade understanding of a DI importance for project. Not enough time for proper DI implementation with lazy allocation and proper deallocation of dependencies.

**Environments** Went with the quickest approach for url and it's safe to share (because it's public api). Deffenietly need a better approach with possibility to maintain environments (easiest one is xcconfig but there are better and safer solutions).

**Search runs on the server.** The API filters by `name` with a regex, so every debounced query is a request.
Matching is case-insensitive even though the API's regex is case-sensitive and rejects inline flags such as `(?i)`:
`NameFilter` turns each letter into a character class (`ger` → `[gG][eE][rR]`) and escapes metacharacters.
The debounce uses Combine. Deduplication runs after the debounce, so a request is compared with the last one
actually issued; typing and erasing a letter within the interval sends nothing.
While a search runs over results already on screen, they stay visible under a progress indicator instead of
being replaced by a full-screen spinner.

**Errors are typed per layer.** Apollo and URLSession errors become `NetworkError` (Networking),
then `CountriesError` (Domain), then `ErrorContent`, the title, message and icon a user sees (Presentation).
Cancellation, including `URLError(.cancelled)`, is never shown as an error.
Out-of-order responses are discarded by a generation counter in the list view model.

**A custom ViewModifier and EnvironmentValues entry, both genuinely needed.**
- `errorState(_:retry:)` replaces a screen with the error view and its Retry button. Both screens used to
  duplicate this block.
- `prefersStackedLayout` is set once at the root by `stackedLayoutPolicy()`, from the Dynamic Type size.
  The list row and the detail rows read it to stack their content vertically at accessibility sizes.
  Previews can force it without changing the text size.

  Why a stored entry plus a modifier: `@Entry` cannot derive its default from another environment value, so
  `stackedLayoutPolicy()` writes it from `dynamicTypeSize`. In exchange, the rule for "too large for side by side"
  lives in one place and can grow beyond text size (for example, size classes) without touching the views.
  The trade-off: a hierarchy without the modifier silently falls back to the side-by-side layout. It is applied
  once in `CountriesObserverApp`. A computed `EnvironmentValues` property returning
  `dynamicTypeSize.isAccessibilitySize` would avoid that, but could not be overridden.

## Deliberately left out

Omitted because of the time limit:

- The details screen does not show what is already known while loading. It shows a spinner, although the flag,
  name and continent come with the tapped list item. The header could render immediately, with placeholders only
  for capital, currency and languages.
  
- Better loading state for search. Current one is quick but can do better with more time.

- Replace the service locator in the coordinator with explicit factories, as described above.
- Inject the Combine scheduler into `CountriesViewModel`, so debounce tests use a test scheduler instead of real
  sleeps.
- Attach the SwiftLint build plugin to the packages as well, and add a SwiftFormat configuration.

Also out of scope:

- Localisation: the copy is English only, with no String Catalog.
- Diacritic-insensitive search: "cote" does not match "Côte d'Ivoire".
- A persistent cache. Apollo's in-memory normalised cache is used.
- UI and snapshot tests.
