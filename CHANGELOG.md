# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_(no unreleased changes yet)_

## [1.0.0] - 2026-09-18

The first tagged release. The snippets had been edited in place since 2023
with no version anyone could point at, and in September 2026 they were
rewritten from scratch, which is the change worth a number.

### Added

- **Two self-contained snippets**, a fixed button and an in-flow stripe, each
  an inline SVG flag beside a `<style>` block, about 2.7 KB of markup and no
  JavaScript. The only network request either can cause is the one a visitor
  makes by clicking the link.
- **`tests/no-external-dependencies.sh`**, run on every push: no `src` or
  `href` reaching outside the file, no `url()` fetching anything, no
  `<script>`, one destination and it is `https://u24.gov.ua/`. Each rule was
  shown a planted violation before it was trusted; the first version of the
  external-reference check used a lookahead that `grep -E` does not support,
  matched nothing, and passed a planted `<link href="font.woff2">` green.
- **Rendered previews** of both snippets under `images/`, produced by a pinned
  headless Chromium so two people get the same pixels.

### Changed

- **The destination is UNITED24**, `https://u24.gov.ua/`, the Ukrainian
  government's own fundraising platform, and it is the same address in both
  files and in the README.
- **The stripe sits in normal document flow** rather than fixed over the page.
  A fixed bar covers whatever is under it, which on most sites is the
  navigation, and then every user of the snippet has to add padding to
  compensate. This one pushes the page down by its own height.
- **The button carries a one-pixel white ring** around the flag so its blue
  half does not vanish against a blue page. Found by rendering it, not by
  reading it.

### Removed

- **A `<script>` tag pulling a widget from a public CDN**, 7,576 bytes of
  JavaScript fetched on every page view of every site using these snippets,
  with no `integrity` attribute: whatever was at that address would execute in
  the page. The repository behind it had not been touched since July 2022 and
  carried no licence. Nothing about it had gone wrong. It is a dependency
  nobody needs for a coloured bar with a flag on it.

[Unreleased]: https://github.com/heyvaldemar/ukraine-support-website-button-stripe/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/heyvaldemar/ukraine-support-website-button-stripe/releases/tag/v1.0.0
