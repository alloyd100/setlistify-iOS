## Master

##### Breaking

* None

##### Enhancements

* None

##### Bug Fixes

* None

## 0.10.0

##### Breaking

* Most properties of `Artwork` are now optional since music video artwork does
  not contain them.
* Return one level more specific instead of `ResponseRoot` for most requests.

##### Enhancements

* Pass errors decoded in `ResponseRoot` as errors in request callback.

##### Bug Fixes

* Fix loading playlists with `apple-curators` curator type.

## 0.9.0

##### Breaking

* `CiderClient` now is initialized with an optional `UrlFetcher` instead of a
  `URLSessionConfiguration`.
* More descriptive generic types for `Resource`.

##### Enhancements

* `UrlFetcher` provides an abstraction for URL loading so that users can choose
  their own mechanism: `URLSession` (default) or another (e.g. Alamofire).
* Add all current `Storefront`s.

##### Bug Fixes

* None

## 0.8.0

##### Breaking

* None

##### Enhancements

* Add functionality to get related resources.
* Add pagination capability to search and relationship requests.
* Add `Playlist`, `MusicVideo`, and `Curator` resources.
* Set caching policy to protocol-defined.

##### Bug Fixes

* None

## 0.7.0

##### Breaking

* None

##### Enhancements

* Add `musicVideos` and `playlists` types.

##### Bug Fixes

* Fix client not initiating network call.

## 0.6.0

##### Breaking

* None

##### Enhancements

* SPM Compatible
* Linux Compatible

##### Bug Fixes

* None

## 0.5.0

##### Breaking

* Rename `Cider` to `CiderClient`

##### Enhancements

* Add include functionality to fetches.
* Increase access level of many fields to `public`

##### Bug Fixes

* None

## 0.4.0

##### Breaking

* Renamed objects to closer match their names in the API spec

##### Enhancements

* Rework API to more closely match Apple Music API Spec

##### Bug Fixes

* Fixed typo in `Cider.artist`
* Add `Genre`

## 0.3.0

##### Breaking

* Rename Amp to Cider

##### Enhancements

* None

##### Bug Fixes

* None

## 0.2.0

##### Breaking

* None

##### Enhancements

* Add stub documentation.
* Add support for cocoapods.

##### Bug Fixes

* None

## 0.1.0

Initial Release
