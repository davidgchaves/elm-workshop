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

#### Record update syntax

```elm
{ model | someData = model.someData + newData }
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


## 3. Adding Interaction

### Booleans

There's not *truthiness*, just booleans:

```elm
type Boolean
    = True
    | False
```

### Partial Application

Elm supports partial application by default

```elm
pluralizeLeaves quantity =
    pluralize "leaf" "leaves" quantity
```

or the more idiomatic

```elm
pluralizeLeaves =
    pluralize "leaf" "leaves"
```

### Anonymous Functions

```elm
isKeepable x = x >= 2
```

vs

```elm
(\x -> x >= 2)
```

### `List.filter`

```elm
List.filter isKeepable     [ 1, 2, 3 ] -- [ 2, 3 ]
List.filter (\x -> x >= 2) [ 1, 2, 3 ] -- [ 2, 3 ]
```

### `List.map`

```elm
List.map (pluralize "leaf" "leaves") [ 1, 2, 3 ]
-- [ "1 leaf", "2 leaves", "3 leaves" ]

List.map (\x -> x * 2) [ 1, 2, 3 ] -- [ 2, 4, 6 ]
```

### Model - View - Update (Elm Architecture)

- All of our application state lives in the `Model`.
- The `Elm Runtime` is going to pass our current `Model` to our `view` function as an argument, in order to get the current `Html`.
- When the user is interacting, `update` takes us from the current `Model` to a new (`update`d) `Model`, based on the user interaction.

1. User does something.
2. We get a `Message` from the `Elm Runtime`.
2. We `update` the `Model` according to the `Message`.
3. `view` gets run once more with the new `Model`.
4. New `Html` is produced.
5. The `Elm Runtime` takes care of the rest.

### Update and Message Example with a Record as the Message

```elm
button
    [ onClick { operation = "SHOW_MORE", data = 10 } ]
    [ text "Show More" ]

update msg model =
    if msg.operation == "SHOW_MORE" then
        { model | maxResults = model.maxResults + msg.data }
    else
        model
```

### Update and Message Example with a Union Type as the Message

```elm
type Msg
    = ShowMore Int

button
    [ onClick (ShowMore 10) ]
    [ text "Show More" ]

update msg model =
    case msg of
        ShowMore n ->
            { model | maxResults = model.maxResults + n }
```

### References

- [The Elm Architecture](http://guide.elm-lang.org/architecture/)
- [`onClick` documentation](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/Html-Events#onClick)
- [record update syntax reference](http://elm-lang.org/docs/syntax#records) (e.g. `{ model | query = "foo" }`)


## 4. Annotations

### Type Aliases

A **type alias** gives a name to a new type.

```elm
type alias SearchResult =
    { id : Int
    , name : String,
    , stars : Int
    }

type alias Model =
    { query : String
    , results : List SearchResults
    }

type alias Msg =
    { operation : String
    , data : String
    }
```

### Function Annotations

```elm
view : Model -> Html Msg
view model =
    button
        [ onClick { operation = "RESET", data = "all" } ]
        [ text "Reset All" ]

update : Msg -> Model -> Model
update msg model =
    if msg.operation == "RESET" then
        { model | query = "", results = [] }
    else
        model
```

#### What about `Html Msg`?

`Html Msg` represents a chunk of `Html` (a virtualDOM structure), where the event handlers produce this type of `Msg`.

For everything to work as it should, the event handlers in the `view` should produce the exact same type of `Msg` that `update` expects.

### Curry and Partial Application

A language that supports **currying** is a language where you can do **partial application**.

All functions in Elm are curried (so they support partial application).

### References

- [Type Annotation syntax reference](http://elm-lang.org/docs/syntax#type-annotations)
- [`type alias` syntax reference](http://elm-lang.org/docs/syntax#type-aliases)


## 5. Union Types

### case-expressions

`case ... of ...`

```elm
case msg.operations of
    "DELETE_BY_ID" -> -- remove from model
    "LOAD_RESULTS" -> -- load more results
    _              -> -- default branch
```

### Creating and Using Union Types

```elm
type Sorting      -- Sorting    is a TYPE
    = Ascending   -- Ascending  is a CONSTANT VALUE
    | Descending  -- Descending is a CONSTANT VALUE
    | Randomized  -- Randomized is a CONSTANT VALUE

case currentSorting of
    Ascending  -> -- sort ascending  here
    Descending -> -- sort descending here
    Randomized -> -- sort randomized here
```

### Parameterized Constructors in Union Types

```elm
type Sorting             -- Sorting    is a TYPE
    = Ascending String   -- Ascending  is a FUNCTION
    | Descending String  -- Descending is a FUNCTION
    | Randomized         -- Randomized is a CONSTANT VALUE
```

Both `Ascending` and `Descending` have a `String -> Sorting` signature.

### Using Parameterized Union types

```elm
case currentSorting of
    Ascending colName  -> -- sort ascending  code here
    Descending colName -> -- sort descending code here
    Randomized         -> -- sort randomized code here
```

### Representing `Msg` as a Union Type

This is the preferred way to deal with `Msg`.

```elm
type Msg
    = SetQuery String
    | DeletedBy Int

case msg of
    SetQuery query -> -- set query in the model here
    DeletedBy id   -> -- delete the result with this id here
```

### Tip: Wiring up `Debug.log`

```elm
-- Debug.log : String -> a -> a

logMeValue |> Debug.log "logMeValue is"
```

### References

- [**case-expressions**](http://elm-lang.org/docs/syntax#conditionals)
- [Union Types syntax reference](http://elm-lang.org/docs/syntax#union-types)


## 6. Decoding JSON

### `Result` Type

```elm
type Result error value
    = Ok value
    | Err error

String.toInt "42" -- Ok 42
String.toInt "Si" -- Err "umm Si is not an int"
```

### `Maybe` Type

```elm
type Maybe
    = Just value
    | Nothing

List.head [ 5, 10, 15 ] -- Just 5
List.head []            -- Nothing
```

#### Tip: Operating with `Maybe`s

You can use `Maybe.withDefault` or `Maybe.map` to avoid repetitive tasks:

```elm
-- withDefault : a -> Maybe a -> a
-- map : (a -> b) -> Maybe a -> Maybe b

[ 1, 2, 3 ]
     |> List.head
     |> Maybe.withDefault 0
-- 1 : Number

[]
     |> List.head
     |> Maybe.withDefault 0
-- 0 : Number

[ 1, 2, 3 ]
     |> List.head
     |> Maybe.map (\x -> x + 10)
-- Just 11 : Maybe number
```

### Pipelines

The `|>` operator inserts the result from the previous step as the final argument in the current step.

```elm
[ 2, 4, 6, 8]
    |> List.filter (\n -> n < 5)
    |> List.reverse
    |> List.map negate
    |> List.head
```

### Decoders (from JSON to Elm)

`float` decoder in action:

```elm
"123.45"
    |> decodeString float
-- Ok 134.45

"blah"
    |> decodeString float
-- Err "blahhh is not a float!"
```

Decoders are composable:

```elm
"[1, 2, 3]"
    |> decodeString (list int)
-- Ok [ 1, 2, 3 ]
```

### Decoding Objects into Records

#### Take 1 (Naïve)

```elm
makeGameState score playing =
    { score = score, playing = playing }

decoder =
    decode makeGameState
        |> required "score" float
        |> required "playing" bool

"""{"score": 5.5, "playing": true }"""
    |> decodeString decoder
-- Ok { score = 5.5, playing = True }
```

#### Take 2 (Idiomatic)

If you create a `type alias` for a `record`, you get a constructor for that type (well, a function) for free:

```elm
-- The GameState type alias...
type alias GameState =
    { score: Float
    , playing: Bool
    }

-- ...gives you a GameState function...
GameState : Float -> Bool -> GameState

-- ...equivalent to the previous makeGameState
makeGameState : Float -> Bool -> GameState
makeGameState score playing =
    { score = score, playing = playing }
```

```elm
type alias GameState =
    { score: Float
    , playing: Bool
    }

decoder =
    decode GameState
        |> required "score" float
        |> required "playing" bool

"""{"score": 5.5, "playing": true }"""
    |> decodeString decoder
-- Ok { score = 5.5, playing = True }
```

### Uppercase functions in Elm

There's only two cases:

- **Case 1**: Function for constructing a `type alias` for a `record`.
- **Case 2**: Function for constructing a Parameterized Union Type.


### `"""` in Elm

`"""` in Elm is for when you want to make a string that:

- can have `"` in it.
- can be multiline.


### References

- [`Maybe` documentation](http://package.elm-lang.org/packages/elm-lang/core/5.0.0/Maybe)
- [`Result` documentation](http://package.elm-lang.org/packages/elm-lang/core/5.0.0/Result)
- [JSON decoding](http://guide.elm-lang.org/interop/json.html)
- [`Json.Decode` documentation](http://package.elm-lang.org/packages/elm-lang/core/5.0.0/Json-Decode)
- [`elm-decode-pipeline` documentation](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest)
