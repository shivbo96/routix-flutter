# Changelog

## 1.0.6

* Added `anonymous_device_id` persistence and automated mapping to event metadata payloads to resolve conversion attribution gaps.

## 1.0.5

* Added Android namespace `link.routix.sdk` to comply with modern Gradle requirements.
* Updated iOS podspec author email.
* Upgraded Dart dependencies (`http` to `^1.5.0`, `device_info_plus` to `^12.4.0`, `package_info_plus` to `^9.0.1`, and `shared_preferences` to `^2.5.5`).

## 1.0.4

* Unified versioning across all Routix SDKs.
* Standardized README structure with clear Direct vs. Deferred flow distinction.
* Improved attribution reliability with expanded device metadata capture (Screen size, Timezone).
* Added official support for unified event tracking schemas (`trackSale`, `trackCustomEvent`).

## 1.0.3

* Update documentation URLs and support links in README.

## 1.0.2

* Update README documentation links.

## 1.0.1

* Update repository URL to point to the dedicated SDK repository.

## 1.0.0

* Initial release of the Routix Flutter SDK.
* Features:
    * Attribution tracking for deep links.
    * Event tracking (e.g., app installs, custom conversions).
    * Deferred deep linking support.
    * Easy integration with simple API.
