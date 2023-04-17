# Changelog

## 0.2.1

* Add a debug header for queue priority classification for your request

## 0.2.0

* Added concept of immediate fail conditions. i.e. when exceeding max concurrent active requests, immediately fail requests under the matching conditions.
* Added ability to specify one or more regex patterns for matching user agents for skip, fail + priority rules

## 0.1.0

Initial alpha testing release. Bringing some minor amount of configurability + a working queue system with some smartish defaults.
