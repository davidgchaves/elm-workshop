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


## 1. Rendering a Page

### Expressions

An **EXPRESSION** evaluates to a single value.

### if-expressions

Every `if` must come with a `then` and an `else`, because `if ... then ... else ...` is an **EXPRESSION** in Elm.

```elm
pluralize singular plural quantity =
    if quantity == 1 then singular else plural
```

### References

- [**if-expressions**](http://elm-lang.org/docs/syntax#conditionals)
- [elm-html documentation](http://package.elm-lang.org/packages/elm-lang/html/latest)
- [html-to-elm](http://mbylstra.github.io/html-to-elm/) - paste in HTML, get elm-html code


## 2. Basic Data Structures

### Strings

Use:

- `++` to concatenate.
- `toString` to convert anything into a String.

### let-expressions

`let ... in ...`

```elm
pluralize singular plural quantity =
    let
        prefix = toString quantity ++ " "
    in
        if quantity == 1 then
            prefix ++ singular
        else
            prefix ++ plural
```

`quantityStr` and `prefix` constants are inaccessible to outside scope.

### Collections: Records

- Data holders.
- Fix length.
- Mixed contents.
- Deceitfully similar to JavaScript Objects:
	- Flat, immutable data structure that hold on to values.
	- No inheritance.
	- No methods.
	- No local state.

```elm
record =
    { name = "thing", x = 1, y = 3 }
record.name -- "thing"
record.x    -- 1
record.y    -- 3
```

### Collections: Lists

- All Lists must contain elements that share a common type.
- Variable length.
- Uniform contents.

```elm
list =
    [ 1, 2, 3 ]

listOfLists =
    [ [ "foo", "bar" ], [ "baz" ] ]

invalidList =
    [ 1, "one" ]
```

### References

- [**let-expressions**](http://elm-lang.org/docs/syntax#let-expressions)
- [record syntax](http://elm-lang.org/docs/syntax#records) (e.g. `{ foo = 1, bar = 2 }`)
- [`List.map` documentation](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/List#map)
