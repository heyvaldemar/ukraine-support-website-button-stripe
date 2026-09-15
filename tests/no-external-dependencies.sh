#!/bin/bash
# The README of this repository makes one claim: these snippets add nothing to
# a page except themselves. No CDN, no script, no font, no image file.
#
# A claim on a public page that nothing re-reads is a claim that stays there
# after it stops being true. Adding a web font "just for the button", or a
# tracking pixel, or pulling the flag from an image host, would each be a
# one-line change that leaves the README lying to everyone who pasted this into
# their site on the strength of it.
#
# So the claim is the test. It runs on every push and pull request.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

# The one address a visitor may be sent to, and only by clicking.
DESTINATION="https://u24.gov.ua/"
FILES=(ukraine-support-website-button.html ukraine-support-website-stripe.html)

PASSED=0; FAILED=0
pass() { echo "  PASS: $1"; PASSED=$((PASSED+1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED+1)); }

echo "=== do these snippets add anything to a page but themselves? ==="
echo

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    fail "$f is missing — the files this repository exists to ship"
    continue
  fi

  # 1. NOTHING EXECUTES. Not a <script> tag, not an inline handler, not a
  #    javascript: url. The snippets are a link and a stylesheet.
  if grep -qiE '<script|javascript:|[[:space:]]on[a-z]+[[:space:]]*=' "$f"; then
    fail "$f contains something executable"
    grep -inE '<script|javascript:|[[:space:]]on[a-z]+[[:space:]]*=' "$f" | head -3 | sed 's/^/        /'
  else
    pass "$f has nothing to execute"
  fi

  # 2. NOTHING IS FETCHED. Every absolute URL in the file is compared against
  #    the destination; anything else would be a request a visitor's browser
  #    makes because this snippet is on the page.
  #    The SVG namespace is a URL and is not a request: it is an identifier
  #    that no browser resolves.
  strays="$(grep -ohE 'https?://[^"'"'"' )]+' "$f" \
            | grep -vFx "$DESTINATION" \
            | grep -v '^http://www\.w3\.org/' \
            | sort -u)"
  if [ -n "$strays" ]; then
    fail "$f names an address other than the destination"
    printf '%s\n' "$strays" | sed 's/^/        /'
  else
    pass "$f fetches nothing: the only address in it is the destination"
  fi

  # 3. NO LOCAL FILE EITHER. src= or url() pointing at a path would be a
  #    request too, and would break the moment somebody pastes the snippet
  #    into a site whose directory layout is not this one.
  #
  #    THE FIRST VERSION OF THIS CHECK COULD NOT MATCH ANYTHING. It carried a
  #    (?!#) lookahead, which is PCRE; grep -E does not have lookaheads, and
  #    the pattern silently matched nothing at all. A planted <link
  #    href="font.woff2"> sailed past it while the other five checks caught
  #    their violations. Found by trying to break each one on purpose, which
  #    is the only reason any of them is believed.
  refs="$(grep -ohE '(src|href)="[^"]+\.(js|css|png|jpe?g|gif|svg|webp|woff2?|ico)"' "$f" | sort -u)"
  urls="$(grep -ohE 'url\([^)]+\)' "$f" | grep -vE 'url\(["'"'"']?#' | sort -u)"
  if [ -n "$refs$urls" ]; then
    fail "$f references a file, which is a request wherever it is pasted"
    printf '%s\n%s\n' "$refs" "$urls" | grep -v '^$' | sed 's/^/        /'
  else
    pass "$f references no file of its own"
  fi

  # 4. THE DESTINATION OPENS SAFELY. target=_blank without rel=noopener hands
  #    the opened page a handle on the opener.
  if grep -q 'target="_blank"' "$f" && ! grep -q 'rel="noopener noreferrer"' "$f"; then
    fail "$f opens a new tab without rel=noopener noreferrer"
  else
    pass "$f opens its link safely"
  fi

  # 5. IT SAYS WHERE IT GOES. A link whose text is a flag and two words needs
  #    an accessible name that names the destination.
  if grep -q 'aria-label=' "$f"; then
    pass "$f carries an accessible name"
  else
    fail "$f has no aria-label, so a screen reader announces only the text"
  fi
done

# 6. AND THE README MUST NOT PROMISE A DIFFERENT DESTINATION FROM THE FILES.
#    The number in the README is the one people read; the href is the one they
#    get. They drift apart the first time somebody edits only one.
if grep -qF "$DESTINATION" README.md; then
  pass "the README names the same destination the files use"
else
  fail "the README does not name $DESTINATION, which is where the files actually point"
fi

echo
echo "passed: $PASSED   failed: $FAILED"
[ "$FAILED" -eq 0 ]
