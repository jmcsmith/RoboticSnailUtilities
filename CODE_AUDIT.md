# CODE_AUDIT.md — RoboticSnailUtilities

**Audited:** 2026-06-10 · 877 LOC across 13 Swift files · swift-tools-version 5.6 · iOS 18.0 minimum
**Compiler ground truth:** clean build, zero warnings in default (Swift 5) mode; 4 warnings under `SWIFT_STRICT_CONCURRENCY=complete`, all rooted in `Binding.withDefault` (see §3.1).
**Method:** full manual read of every source file, iOS Simulator build + strict-concurrency build, SwiftUI expert pass (swiftui-expert-skill), concurrency pass (swift-concurrency-pro).

---

## 1. Executive summary

1. **[High] Unstable `UUID()` identity in public models breaks SwiftUI diffing** — §5.1 — `Sources/RoboticSnailUtilities/AppIconPicker/AppIconOption.swift:14`
2. **[High] Force unwrap in `UIImage.fixOrientation()` can crash, and the API it uses is deprecated** — §5.2 / §4.2 — `Sources/RoboticSnailUtilities/Extensions.swift:120`
3. **[High] `LogStore.export()` scans 24h of OSLog synchronously on the main actor — UI hang** — §7.1 — `Sources/RoboticSnailUtilities/LogStore.swift:32-46`
4. **[High] 4 strict-concurrency warnings in `Binding.withDefault` become errors under Swift 6** — §3.1 — `Sources/RoboticSnailUtilities/Extensions.swift:89-97`
5. **[Medium] Onboarding title symbol hardcodes `.yellow`, ignoring the page's `tint`** — §8.3 — `Sources/RoboticSnailUtilities/Onboarding/OnboardingPageCardView.swift:12`
6. **[Medium] Double 22pt horizontal padding (44pt total inset) on onboarding cards** — §8.4 — `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowView.swift:49` + `OnboardingPageCardView.swift:47`
7. **[Medium] App-icon preview images are read aloud by VoiceOver as asset names; selected state has no trait** — §8.1 — `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:31-63`
8. **[Medium] Test target is an empty stub — zero coverage on a published utility package** — §9.4 — `Tests/RoboticSnailUtilitiesTests/RoboticSnailUtilitiesTests.swift:4-11`
9. **[Medium] Package manifest is on tools 5.6 / Swift 5 mode; no `Sendable` on any public model** — §3.2 — `Package.swift:1`

---

## 2. Quick wins (≤30 minutes each)

### 2.1 Stale file-header comments from other projects
- **Location:** `Sources/RoboticSnailUtilities/LogStore.swift:3` ("LoggerTest"), `AppIconPicker/AppIconOption.swift:3`, `AppIconRow.swift:3`, `AppIconPicker.swift:3` (all "icons")
- **What:** Headers name the throwaway projects the files were copied from.
- **Action:** Update or delete the header blocks.
- **Severity:** Low

### 2.2 Commented-out code
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:129`
- **What:** `//formatter.allowedUnits = [...]` left in `Double.asString(style:)`.
- **Action:** Delete (or make it a real parameter — see §4.5).
- **Severity:** Low

### 2.3 Deprecated `Section(header:)` positional initializer
- **Location:** `Sources/RoboticSnailUtilities/SupportLinksSections.swift:79`, `AppIconPicker/AppIconPicker.swift:23`
- **What:** Uses the renamed/deprecated `Section(header: Text(...))` form; `SupportLinksSections.swift:98` already uses the modern single-title form, so the file is internally inconsistent.
- **Action:** Use `Section("Title")` or the trailing-closure `Section { } header: { }` form everywhere.
- **Severity:** Low

### 2.4 `foregroundColor` → `foregroundStyle`
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:52`
- **What:** Last remaining `foregroundColor(.secondary)`; the rest of the package already uses `foregroundStyle`.
- **Action:** Swap to `foregroundStyle(.secondary)`.
- **Severity:** Low

### 2.5 `cornerRadius(_:)` → `clipShape(.rect(cornerRadius:))`
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:34, 39, 45`
- **What:** `cornerRadius` is deprecated since iOS 15.
- **Action:** Replace with `clipShape(.rect(cornerRadius: 8))` at all three sites.
- **Severity:** Low

### 2.6 Warning logged through the wrong logger
- **Location:** `Sources/RoboticSnailUtilities/LogStore.swift:44`
- **What:** The `catch` block calls `Self.logger.warning(...)` (the 🟢 category) instead of the dedicated `Self.warning` logger (🟡), so the store's own warnings are mis-categorized.
- **Action:** Route through `Self.warning`.
- **Severity:** Low

### 2.7 `Package.swift` template cruft
- **Location:** `Package.swift:8` (mis-indented `platforms:`), boilerplate comments throughout
- **What:** Manifest still carries scaffold comments and inconsistent indentation.
- **Action:** Clean up alongside the tools-version bump in §3.2.
- **Severity:** Low

---

## 3. Concurrency

### 3.1 `Binding.withDefault` fails strict concurrency (4 compiler warnings)
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:89-97`
- **What:** Strict-concurrency build emits: capture of `self` (non-Sendable `Binding<Optional<T>>`) at 92:13 and 94:13, capture of `defaultValue` (non-Sendable `T`) at 92:34, and "requires that 'T' conforms to 'Sendable'" at 92:34. `Binding` is only `Sendable` when its `Value` is `Sendable`, and the generic `T` is unconstrained.
- **Why:** These become hard errors the moment the package (or a consuming app) adopts Swift 6 language mode. Notably the typed `String?`/`Date?` overloads at lines 71-88 don't warn, because those `Value` types are `Sendable` — confirming the fix.
- **Action:** Constrain the generic helper to `T: Sendable` (matching SwiftUI's own conditional `Binding: Sendable` conformance). Then consider deleting the now-redundant typed overloads (§9.2).
- **Severity:** High

### 3.2 Tools version 5.6 / Swift 5 mode; no `Sendable` declarations on public API
- **Location:** `Package.swift:1`; models at `AppIconPicker/AppIconOption.swift:13`, `Onboarding/OnboardingPage.swift:3`, `Onboarding/OnboardingFeature.swift:3`, `SupportLinksSections.swift:3, 17`
- **What:** The manifest pins swift-tools-version 5.6 (March 2022), so the package builds in Swift 5 mode with minimal concurrency checking, and none of the public value-type models declare `Sendable`. Public (non-frozen) structs do **not** get implicit `Sendable` across module boundaries, so consumers in Swift 6 mode can't pass these models across isolation domains.
- **Why:** Swift-6-mode consumers hit avoidable diagnostics; the package itself isn't validating its own concurrency story (the §3.1 warnings are invisible at the current tools version).
- **Action:** Bump to swift-tools-version 6.x (or at minimum 5.9 + `StrictConcurrency` upcoming feature), use `.iOS(.v18)`, declare `Sendable` on `AppIconOption`, `OnboardingPage`, `OnboardingFeature`, `SocialLinkItem`, `AboutLinkItem` (all are `let`-only value types with Sendable members), and fix §3.1.
- **Severity:** High

### 3.3 Completion-handler icon change can be the modern async API
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:15, 72-95`
- **What:** `setIcon()` bridges `setAlternateIconName(_:completionHandler:)` back to the main actor via `Task { @MainActor in ... }` and serializes calls with a static `iconChangeInFlight` flag. The code is *correct* as written (flag is `@MainActor`-isolated; completion hops back properly) — but UIKit provides `try await UIApplication.shared.setAlternateIconName(_:)`.
- **Why:** The async form removes the manual hop, makes the error path explicit, and lets the in-flight guard become local view state (e.g., a `@State` task) instead of type-level static mutable state shared by every row in the process.
- **Action:** Refactor `setIcon()` to an async method using the throwing async API; on failure, restore `selectedIconName` from `UIApplication.shared.alternateIconName` as today.
- **Severity:** Medium

---

## 4. API modernity

### 4.1 `ObservableObject` → `@Observable`
- **Location:** `Sources/RoboticSnailUtilities/LogStore.swift:11, 30`
- **What:** `LogStore` uses `ObservableObject` + `@Published`. The package targets iOS 18; the iOS 17+ `@Observable` macro is the recommended replacement and gives per-property observation granularity.
- **Why:** Consumers currently must use `@StateObject`/`@ObservedObject` (the README example shows `@StateObject`); `@Observable` enables plain `@State` ownership and fewer spurious view updates.
- **Action:** Migrate to `@Observable` and update the README usage example. Coordinate with §7.1 since `export()`'s shape will change anyway.
- **Severity:** Medium

### 4.2 Deprecated `UIGraphicsBeginImageContextWithOptions` family
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:116-121`
- **What:** `UIImage.fixOrientation()` uses `UIGraphicsBeginImageContextWithOptions` / `UIGraphicsGetImageFromCurrentImageContext` / `UIGraphicsEndImageContext`, formally deprecated in iOS 17.
- **Why:** Deprecated API plus a force-unwrap crash vector (§5.2). `UIGraphicsImageRenderer` is the supported replacement and never returns nil.
- **Action:** Rewrite using `UIGraphicsImageRenderer` with a format matching the source image's scale; this also resolves §5.2.
- **Severity:** High (paired with §5.2)

### 4.3 Legacy text-field style spellings
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:16, 18`
- **What:** `RoundedBorderTextFieldStyle()` / `PlainTextFieldStyle()` instead of the modern `.roundedBorder` / `.plain` member syntax.
- **Action:** Use the leading-dot members. (The deeper structural issue with this helper is §5.4.)
- **Severity:** Low

### 4.4 `DateFormatter` with hardcoded pattern for weekday names
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:98-104`
- **What:** `Date.dayOfWeek()` allocates a `DateFormatter` per call, sets a fixed `"EEEE"` pattern, and `.capitalized`-izes the result.
- **Why:** Per-call formatter allocation is expensive (§7.2); fixed patterns bypass locale-aware formatting; `.capitalized` produces wrong results in some locales (weekday names are already correctly cased by the formatter).
- **Action:** Replace with `formatted(.dateTime.weekday(.wide))` (FormatStyle is cached internally and locale-correct); drop `.capitalized`.
- **Severity:** Medium

### 4.5 `DateComponentsFormatter` allocated per call
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:126-133`
- **What:** `Double.asString(style:)` builds a `DateComponentsFormatter` on every invocation and silently returns `""` on failure. No `allowedUnits` are set, so output depends on formatter defaults.
- **Action:** Prefer `Duration.seconds(self).formatted(.units(...))` or `.formatted(.time(pattern:))`; if `DateComponentsFormatter` must stay, cache it statically and set explicit `allowedUnits`. Same FormatStyle note applies to `Float.clean` at lines 105-109 (`String(format:)` → `formatted(...)`).
- **Severity:** Medium

---

## 5. Bugs / logic errors

### 5.1 Fresh `UUID()` identity on every model instantiation
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconOption.swift:14` (`public let id = UUID()`, not injectable); `Onboarding/OnboardingPage.swift:11` and `Onboarding/OnboardingFeature.swift:10` (injectable but defaulted to `UUID()`)
- **What:** Identity is minted at init. Any consumer who builds the `options`/`pages` array inside a view `body` (a completely natural call pattern for a library like this) gets new IDs on every render.
- **Why:** `ForEach` sees all-new identities each pass: row state resets, animations/transitions break (the `.transition(.opacity)` checkmark in `AppIconRow` and the `.animation(value:)` in `AppIconPicker` depend on stable identity), and diffing degrades to full rebuilds. Bonus defect: the synthesized `Equatable` on `AppIconOption` includes `id`, so two identical options are never equal.
- **Action:** Derive identity from content — e.g., `AppIconOption.id` as `alternateIconName ?? title` — or at least make `id` injectable and exclude it from `Equatable`. Document the requirement for stable IDs in the README.
- **Severity:** High

### 5.2 Force unwrap of a nullable graphics context result
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:120`
- **What:** `UIGraphicsGetImageFromCurrentImageContext()!` — returns nil when the context wasn't created (e.g., zero-sized image, which happens in practice with failed decodes) and crashes.
- **Why:** Library code should never crash the host app on a degenerate input.
- **Action:** Fixed for free by the `UIGraphicsImageRenderer` rewrite (§4.2); otherwise guard-let and return `self` as fallback.
- **Severity:** High

### 5.3 Unclamped page index into `pages`
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowView.swift:60`
- **What:** `pages[selectedPage].tint` — `selectedPage` is `@State`, so if a consumer passes a shorter `pages` array after the user has advanced (dynamic/remote-configured onboarding), this traps out of range.
- **Action:** Clamp (`pages[min(selectedPage, pages.count - 1)]`) or reset `selectedPage` via `onChange(of: pages.count)`.
- **Severity:** Medium

### 5.4 `editingStyle(if:)` swaps structural identity of the TextField
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:12-21`
- **What:** The `if/else` in the `@ViewBuilder` produces two different concrete types, so toggling the flag destroys and recreates the field.
- **Why:** A focused text field loses first-responder status (keyboard dismisses) and any internal state mid-edit — exactly when an "editing style" toggle fires.
- **Action:** Keep one structural identity: apply a single style and vary only appearance (e.g., a background/overlay that changes with the flag), or document the limitation prominently.
- **Severity:** Medium

### 5.5 Default IDs collide when titles repeat
- **Location:** `Sources/RoboticSnailUtilities/SupportLinksSections.swift:9-14, 24-36`
- **What:** `SocialLinkItem`/`AboutLinkItem` default `id` to `title`. Two rows with the same title (plausible across sections or after localization) produce duplicate `ForEach` IDs — undefined behavior.
- **Action:** Default `id` to something unique-ish (title + URL string) or document that titles must be unique.
- **Severity:** Low

### 5.6 Inconsistent nil-URL handling between sections
- **Location:** `Sources/RoboticSnailUtilities/SupportLinksSections.swift:86-90` vs `100-105`
- **What:** A social item with `url == nil` renders an inert `Text` row; an about item with `url == nil` is silently dropped.
- **Action:** Pick one behavior (suggest: drop in both, since a link row without a link is dead UI) and document it.
- **Severity:** Low

### 5.7 `Color.toHex()` breaks for non-RGB colors
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:167-186`
- **What:** Reads `cgColor.components` directly without converting to sRGB. Grayscale colors (e.g., `Color.white` → 2 components) return nil; Display-P3 colors return wrong hex values; round-tripping `Color(hex:)` output isn't guaranteed.
- **Action:** Convert via `UIColor` to the sRGB color space (or use `UIColor.getRed(_:green:_:alpha:)`) before extracting components. Consider also supporting 3-digit shorthand in `Color(hex:)` at lines 135-166 while in there.
- **Severity:** Medium

---

## 6. Security

### 6.1 Exported log entries may carry sensitive data
- **Location:** `Sources/RoboticSnailUtilities/LogStore.swift:38-42`
- **What:** `export()` surfaces raw `composedMessage` strings for the app's whole subsystem. Not a vulnerability in this package, but consumers wiring this to a share sheet / support email will ship whatever was logged, including values logged with `privacy: .public`.
- **Action:** Add a README note advising consumers to review what their loggers emit before exposing `entries` in UI or exports.
- **Severity:** Low

_No other findings — the package has no networking, credential handling, or dynamic code paths._

---

## 7. Performance

### 7.1 Synchronous 24-hour OSLog scan on the main actor
- **Location:** `Sources/RoboticSnailUtilities/LogStore.swift:32-46`
- **What:** `LogStore` is `@MainActor`, and `export()` synchronously opens `OSLogStore` and enumerates every entry from the last 24 hours, filtering and mapping in-line. On a chatty app this is easily hundreds of milliseconds to seconds of main-thread work.
- **Why:** Guaranteed UI hang exactly when the user opens a debug/log screen.
- **Action:** Make `export()` `async`, perform the store read and filtering in a `nonisolated` async function (or background task), then assign `entries` back on the main actor. Consider making the 24-hour window a parameter, and note that `getEntries` returns oldest-first — newest-first is usually what log UIs want.
- **Severity:** High

### 7.2 Per-call formatter allocation
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:100, 128`
- **What:** `DateFormatter` and `DateComponentsFormatter` constructed on every invocation; both are expensive to create and these helpers are the kind that get called in list rows.
- **Action:** Covered by the FormatStyle migrations in §4.4/§4.5 (FormatStyle caches internally).
- **Severity:** Medium

---

## 8. SwiftUI / UI

### 8.1 AppIconRow VoiceOver experience
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:31-63`
- **What:** Three issues in one row: (a) preview `Image(option.lightPreview)` etc. are asset-name accessibility elements, so VoiceOver reads "AppIconGreenLight" before the title; (b) the checkmark `Image(systemName:)` is not hidden, so VO appends "checkmark"; (c) the selected row carries no `.isSelected` trait.
- **Action:** Use `Image(decorative:)` for the three previews, `.accessibilityHidden(true)` on the checkmark, and `.accessibilityAddTraits(.isSelected)` (conditionally) on the button — or group the row with `.accessibilityElement(children: .combine)` plus an explicit value.
- **Severity:** Medium

### 8.2 Fixed 40pt icon previews don't scale with Dynamic Type
- **Location:** `Sources/RoboticSnailUtilities/AppIconPicker/AppIconRow.swift:33, 38, 44`
- **What:** Hardcoded `frame(width: 40, height: 40)` next to scaling text.
- **Action:** Drive the size with `@ScaledMetric(relativeTo: .body)`.
- **Severity:** Low

### 8.3 Title symbol hardcodes `.yellow`, ignoring the page tint
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingPageCardView.swift:12`
- **What:** Feature icons use `page.tint` (line 27) but the title symbol is fixed `.foregroundStyle(.yellow)` — almost certainly a leftover from a specific app's design, and invisible-adjacent on light yellow backgrounds.
- **Action:** Use `page.tint` (or add an optional `titleSymbolTint` to `OnboardingPage` defaulting to the page tint).
- **Severity:** Medium

### 8.4 Double horizontal padding on onboarding cards
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowView.swift:49` + `Onboarding/OnboardingPageCardView.swift:47`
- **What:** The flow view pads each card `.horizontal, 22` and the card pads itself `.horizontal, 22` again — 44pt inset per side, while the footer gets only 22 (`OnboardingFlowView.swift:65`), so card content and footer don't align.
- **Action:** Remove one of the two (suggest the card's internal padding, keeping layout control in the container).
- **Severity:** Medium

### 8.5 Page indicator isn't adjustable for VoiceOver
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowFooterView.swift:19-30`
- **What:** The dots are correctly grouped with a label/value, but VO users can't swipe vertically to change pages the way they can with native page controls.
- **Action:** Add `.accessibilityAdjustableAction` incrementing/decrementing `selectedPage` with bounds checks.
- **Severity:** Low

### 8.6 Footer button: no pressed feedback; contrast risk on light tints
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowFooterView.swift:32-50`
- **What:** The gradient `background` and `overlay` are applied *outside* the `Button`, so the default style's pressed-state dimming applies only to the text, not the capsule. Separately, the label is fixed `.white` over an arbitrary caller-supplied tint — fails contrast for light tints (yellow, mint).
- **Action:** Move the capsule into the label or a custom `ButtonStyle` (which also gives proper pressed scaling/opacity); document the contrast expectation or compute label color from the tint.
- **Severity:** Low

### 8.7 SupportLinksSections styling nits
- **Location:** `Sources/RoboticSnailUtilities/SupportLinksSections.swift:83, 112`
- **What:** (a) `.symbolRenderingMode(.multicolor)` on `Image(item.imageName)` is a no-op unless the asset is a symbol image; (b) the review button hardcodes `.foregroundStyle(.blue)` instead of respecting the app's tint.
- **Action:** Drop the rendering mode (or document that symbol assets are expected); use `.tint`/accent-color-driven styling for the button.
- **Severity:** Low

### 8.8 Hardcoded English strings aren't consumer-localizable
- **Location:** `Sources/RoboticSnailUtilities/SupportLinksSections.swift:53-54, 116, 120`; `Onboarding/OnboardingFlowView.swift:15-16, 85`; `Onboarding/OnboardingFlowFooterView.swift:29-30`
- **What:** Defaults like "Social", "About", "Version", "Build", "Continue", "Get Started", "No onboarding pages configured.", and the accessibility strings "Onboarding progress" / "Page X of Y" resolve against this module with no localization tables, so non-English apps ship English UI from this package.
- **Action:** Either add `defaultLocalization` + a strings catalog with `Bundle.module` lookups, or document that consumers should pass localized strings for every default (the accessibility strings currently can't be overridden at all).
- **Severity:** Medium

### 8.9 Preview/`ForEach` modernization nits
- **Location:** `Sources/RoboticSnailUtilities/Onboarding/OnboardingFlowView.swift:46-48, 96-110`
- **What:** (a) `ForEach(Array(pages.enumerated()), id: \.element.id)` tags rows by *index* while identifying by *element id* — works, but selection and identity diverge if pages ever reorder; (b) the `#Preview` uses `.constant(false)` where `@Previewable @State` (iOS 18) would exercise the real completion flow.
- **Action:** Tag by `page.id` and make `selectedPage` an ID-based selection, or accept index-based and use `id: \.offset`; adopt `@Previewable` in the preview.
- **Severity:** Low

---

## 9. Dead code / duplication / refactor

### 9.1 `DebugBorder` modifier is dead and diverges from the extension
- **Location:** `Sources/RoboticSnailUtilities/DebugBorder.swift:11-19` vs `21-28`
- **What:** The public `DebugBorder` `ViewModifier` is never used — `View.debugBorder(color:)` reimplements the overlay inline. Worse, the modifier is *not* `#if DEBUG`-gated while the extension is, so the two public spellings have different release behavior.
- **Action:** Make the extension apply the modifier and gate both behind `#if DEBUG` (or delete the modifier). Note: the `DEBUG` flag reflects how the *package* is compiled, which under SPM follows the app's configuration — worth a comment.
- **Severity:** Medium

### 9.2 Redundant typed `Binding` default-value overloads
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:71-97`
- **What:** `withDefaultValue(_:)` for `String?` and `Date?` duplicate the generic `withDefault(_:)`; three public APIs, two names, one behavior.
- **Action:** After constraining the generic to `Sendable` (§3.1), deprecate the typed overloads in favor of one generic with one name.
- **Severity:** Low

### 9.3 `Extensions.swift` is a grab-bag with a CoreData import tax
- **Location:** `Sources/RoboticSnailUtilities/Extensions.swift:1-187`
- **What:** One file mixes SwiftUI view helpers, `Binding` utilities, CoreData, `UIImage`, `Color`, collection algorithms, and formatting — and imports CoreData for a single 8-line `saveIfNeeded()` helper.
- **Action:** Split by domain (`Binding+Defaults.swift`, `Color+Hex.swift`, `Collection+Utilities.swift`, etc.). Consider whether CoreData belongs in a SwiftUI utilities package at all — a separate target (or its own tiny package) keeps the dependency surface honest.
- **Severity:** Medium

### 9.4 Test target is an empty stub
- **Location:** `Tests/RoboticSnailUtilitiesTests/RoboticSnailUtilitiesTests.swift:4-11`
- **What:** One XCTest case containing a commented-out assertion. Zero real coverage.
- **Why:** This package is full of cheap-to-test pure logic: `Array.halves()` (empty/odd/even), `Sequence.unique()` (order preservation), `Color(hex:)`/`toHex()` round-trips (including the §5.7 failures), `Float.clean`, `Binding.withDefault` get/set, `saveIfNeeded()` with an in-memory store.
- **Action:** Adopt Swift Testing (`@Test`, `#expect`, parameterized cases) — the tools-version bump in §3.2 enables it — and start with the extension functions and the §5.7 round-trip bug as a regression test.
- **Severity:** Medium

---

## 10. Cross-cutting recommendations

1. **Swift 6 migration as one coordinated change:** bump tools-version (§3.2) → constrain `Binding.withDefault` (§3.1) → add `Sendable` to the five public models → build with strict concurrency in CI. The whole package is small enough to do this in one sitting; the strict build already passes except for the four §3.1 warnings.
2. **Add `AGENTS.md`/`CLAUDE.md`.** The repo has neither (this audit was asked to use one). Document: library purpose, iOS 18 minimum, no-dependency policy, how to build/test from CLI (`xcodebuild -scheme RoboticSnailUtilities -destination 'generic/platform=iOS Simulator'`), and public-API conventions.
3. **Add CI.** A GitHub Actions workflow doing an iOS Simulator build + test with strict concurrency would have caught §3.1 and keeps §9.4's future tests honest.
4. **DocC the public surface.** `AppIconOption` has good doc comments; most other public types/methods have none. The README is strong — mine it for doc comments.
5. **FormatStyle everywhere:** §4.4/§4.5/`Float.clean` all replace legacy formatters with `.formatted(...)` — apply as one pass.
6. **Consider whether iOS 18 is the real floor.** Nothing in the package requires iOS 18 API (LabeledContent is 16+, `Button(_:systemImage:)` is 17+). If adoption matters, iOS 17 is reachable cheaply; if not, document why 18.

---

## 11. What was NOT audited

- Runtime behavior on device/simulator (alternate-icon switching requires `CFBundleIcons` host-app setup; not exercised).
- Asset-dependent rendering (preview images, social icons) — no host app in this repo.
- Localization wording (none exists; see §8.8).
- Instruments profiling — §7.1 is a static-analysis finding; no trace was recorded.
- Build settings beyond the package manifest (no .xcodeproj in repo).
- Third-party dependencies (the package has none).

---

## 12. Verification

- **§3.1** — Compiler-verified: `SWIFT_STRICT_CONCURRENCY=complete` build emitted exactly 4 warnings at `Extensions.swift:92:13`, `92:34` (×2), `94:13`. The `String?`/`Date?` overloads (lines 71-88) emit none, confirming the `Sendable`-constraint fix.
- **§5.1** — Open `Sources/RoboticSnailUtilities/AppIconPicker/AppIconOption.swift`, line 14: `public let id = UUID()` with no `id` parameter in the init (lines 29-43); `Equatable` on line 13 is synthesized over all properties including `id`.
- **§5.2** — Open `Sources/RoboticSnailUtilities/Extensions.swift`, line 120: `UIGraphicsGetImageFromCurrentImageContext()!`; the context is created at line 116 with the unvalidated `self.size`.
- **§7.1** — Open `Sources/RoboticSnailUtilities/LogStore.swift`: class is `@MainActor` (line 11); `export()` (lines 32-46) is synchronous and enumerates `getEntries(at:)` from a 24-hour-ago position (lines 35-39) with no suspension points — all on the main actor.
- **§8.4** — `OnboardingFlowView.swift:49` pads the card `.horizontal, 22`; `OnboardingPageCardView.swift:47` pads `.horizontal, 22` again inside the same card.
