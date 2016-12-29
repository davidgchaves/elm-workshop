# Notes on *Richard Feldman's Workshop: Elm Workshop*


## 0. Setup

### Installation (Node)

1. Install [Node.js](http://nodejs.org) 6.9.2 or higher

2. Not required, but **highly** recommended: [install elm-format](https://github.com/avh4/elm-format#installation-) and integrate it into your editor so that it runs on save. You want the one [for Elm 0.17](https://github.com/avh4/elm-format#for-elm-017).

3. Run the following command to install everything else:

```bash
❯ npm install
```

### Create a GitHub Personal Access Token

We'll be using GitHub's [Search API](https://developer.github.com/v3/search/), and authenticated API access lets us experiment without worrying about the default rate limit. Since we'll only be accessing the Search API, these steps can be done either on your personal GitHub account or on a throwaway account created for this workshop; either way will work just as well.

1. Visit https://github.com/settings/tokens/new
2. Enter "Elm Workshop" under "Token description" and leave everything else blank.
3. Create the token and copy it into a new file called `Auth.elm`:

#### Auth.elm

```elm
module Auth exposing (token)


token =
    -- Your token should go here instead of this sample token:
    "abcdef1234567890abcdef1234567890abcdef12"
```

**Note:** Even for a token that has no permissions, good security habits are
still important! `Auth.elm` is in `.gitignore` to avoid accidentally checking in
an API secret, and you should [delete this token](https://github.com/settings/tokens) when the workshop is over.


### Installation (Elm)

```bash
❯ elm-package install
```

### Building

```bash
❯ elm-live Main.elm --open --pushstate --output=elm.js
```
