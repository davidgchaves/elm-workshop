# Notes on *Richard Feldman's Workshop: Elm Workshop*

## 0. Setup

### Installation (Node)

1. Install [Node.js](http://nodejs.org) 6.9.2 or higher

2. Not required, but **highly** recommended: [install elm-format](https://github.com/avh4/elm-format#installation-) and integrate it into your editor so that it runs on save. You want the one [for Elm 0.17](https://github.com/avh4/elm-format#for-elm-017).

3. Run the following command to install everything else:

```bash
❯ npm install -g elm elm-test elm-css elm-live
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

### Running Tests

Do either (or both!) of the following:

#### Running tests on the command line

```bash
❯ elm-test
```

#### Running tests in a browser

```bash
❯ cd tests
❯ elm-reactor
```

Then visit [localhost:8000](http://localhost:8000) and choose `HtmlRunner.elm`.


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


## 7. Client-Server Communication

### (Pure) Function Guarantees in Elm

1. Same arguments produce the same return value.
2. No Side Effects.

### What is a `Cmd`?

A `Cmd` is some logic that you want to run that does not obey the guarantee that *given the same arguments, a function returns the same result*.

#### Managed Effects with `Http.Request`

```elm
Http.getString : String                          -> Http.Request String
Http.get       : String -> Json.Decode.Decoder a -> Http.Request a
```

#### A `Cmd` example using `Http.send`

`Http.send` sends a `Http.Request` and returns a `Cmd Msg`

```elm
-- Http.send : (Result Http.Error a -> Msg) -> Http.Request a -> Cmd Msg

searchGithubApiCmd : Cmd Msg
searchGithubApiCmd =
    let
        getRequest =
            Http.get "https://api.github.com?q=elm" githubDecoder
    in
        Http.send HandleResponse getRequest

type Msg
    = HandleResponse (Result Http.Error a)
```

### Read it out load

- `Decoder (List SearchResult)`: A `Decoder` of a `List` of `SearchResult`s.
- `Html Msg`: `Html` producing `Msg`.
- `Cmd Msg`: `Cmd` producing/resulting in `Msg`.

### References

- [Running Effects](http://guide.elm-lang.org/architecture/effects/)
- [HTTP Error documentation](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http#Error)
- [Modules syntax reference](http://elm-lang.org/docs/syntax#modules)
- [Html.Keyed documentation](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html-Keyed)


## 8. JavaScript Interop

### Type variables

``` elm
List.reverse : List a -> List a -- where `a` is a TYPE VARIABLE
```

### Data Out (`Cmd`), Data In (`Sub`) Policy

We talk to JavaScript the same way we talk to servers (no direct function calls involved):

- Elm sends data to Javascript (the same way that sends data to a server).
- JavaScript sends data to Elm (the same way that a server sends data to Elm).

#### Elm Land: Exit the Data (`Cmd`)

A `Cmd a` results in data sent into a callback in the JavaScript side.

#### Elm land: Enter the Data (`Sub`)

A `Sub a` results in data received from JavaScript and fed into `update`.

### `Cmd Msg` vs `Cmd msg`

- `Cmd Msg`:
	- produces messages of type `Msg`,
	- works with `update` functions that accept `Msg`.
- `Cmd msg` (or even better `Cmd a`):
	- works with **any** `update` function,
	- does not produce any message.

The behavior of `Cmd a` is also known as **fire-and-forget**.

### To and From JS using `port`s

#### 0. The `port` keyword

`Main.elm`

```elm
port module Main exposing (..)
```

A `port module` means that it can talk to JavaScript.

#### 1. `port searchGithubApiWithJS`

`Main.elm`

```elm
port searchGithubApiWithJS : String -> Cmd a
```

The `searchGithubApiWithJS` `port` sends a `String` to JS land via a `Cmd`:

- `String` means we are sending a `String` into a JavaScript callback.
- `Cmd a` means we are going to send a **fire-and-forget** `Cmd` into a JavaScript callback.
- `port searchGithubApiWithJS` means we are creating an `app.ports.searchGithubApiWithJS` on the JavaScript side.

#### 2. `subscribe`ing in JS land

`main.js`

```javascript
const app = Elm.Main.embed(
  document.getElementById('elm-app')
)

const searchGithub = query => ...

app.ports.searchGithubApiWithJS.subscribe(searchGithub)
```

`app.ports.searchGithubApiWithJS.subscribe(searchGithub)`:

- wires up `searchGithub`
- with the `query` coming from Elm land.

#### 3. `port responseFromGithubApiWithJS`

`Main.elm`

```elm
port responseFromGithubApiWithJS : (Json.Decode.Value -> a) -> Sub a
```

The `responseFromGithubApiWithJS` `port` catches a `Result` from JS land via a `Msg` (the `a`):

- `Json.Decode.Value` represents an unknown shaped JavaScript value.
- `(Value -> a)` decodes the JavaScript value into a `Msg`.
- `Sub a` feeds the `Msg` into `update`.
- `port responseFromGithubApiWithJS` means we are creating an `app.ports.responseFromGithubApiWithJS` on the JavaScript side.

#### 4. `send`ing data from JS land

`main.js`

```javascript
const app = Elm.Main.embed(
  document.getElementById('elm-app')
)

const searchGithub = query =>
  fetch(query)
    .then(res => res.json())
    .then(repos => app.ports.responseFromGithubApiWithJS.send(repos))
```

`app.ports.responseFromGithubApiWithJS.send(repos))`:

- sends the `repos` JS object
- into `responseFromGithubApiWithJS` in Elm land.

#### 5. Wiring up the `Sub`scription in Elm land

`Main.elm`

```elm
main : Program Never Model Msg
main =
    Html.program
        { ...
        , subscriptions = \_ -> responseFromGithubApiWithJS decodeResponseFromJS
        }
```

#### 6. Decoding the JS data in Elm land

`Main.elm`

```elm
subscriptions = \_ -> responseFromGithubApiWithJS decodeResponseFromJS

port responseFromGithubApiWithJS : (Json.Decode.Value -> a) -> Sub a

decodeResponseFromJS : Json.Decode.Value -> Msg
decodeResponseFromJS json =
    HandleGithubResponseFromJS (json |> Json.Decode.decodeValue githubDecoder)

type Msg
    = ...
    | HandleGithubResponseFromJS (Result String (List SearchResult))
```

From `Json.Decode.Value` into `Result String (List SearchResult)` wrapped in a `Msg` constructor.

### The `Elm` object in JS land

The `Elm` object on the JavaScript side contains your Elm modules as fields on it, so `Elm.Main` in JavaScript refers to the `Main` module in Elm.

### References

- [JavaScript and Ports Guide](http://guide.elm-lang.org/interop/javascript.html)
- [fetch API documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)


## 9. Testing

### Unit Tests vs Property Based Tests

```elm
-- unit test
test "Reversing twice does nothing" <|
    \() ->
        [ 1, 2, 3 ]
            |> List.reverse
            |> List.reverse
            |> Expect.equal [ 1, 2, 3 ]

-- property based test with 1 fuzzer
fuzz int "Reversing twice does nothing" <|
    \x ->
        [ 1, 2, x ]
            |> List.reverse
            |> List.reverse
            |> Expect.equal [ 1, 2, x ]

-- property based test composing fuzzers
fuzz (list int) "Reversing twice does nothing" <|
    \xs ->
        xs
            |> List.reverse
            |> List.reverse
            |> Expect.equal xs

-- property based test with 2 fuzzers
fuzz2 int float "Integers are bigger than floats (FAILS)" <|
    \randomInt randomFloat ->
        randomInt
            |> Expect.greaterThan randomFloat
```

### References

* [Using Elm packages](https://github.com/elm-lang/elm-package/blob/master/README.md#basic-usage)
* [elm-test documentation](http://package.elm-lang.org/packages/elm-community/elm-test/latest)
* [`(<|)` documentation](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#<|)


## 10. Delegation

### How to simplify your `Model`?

Reduce the number of fields in your `Model`, by:

1. making a new `type alias` (let's say `SearchOptionsModel`) and,
2. importing it back into your `Model` as a new field (let's say `searchOptions`)

It's like namespacing the `Model`.

#### Simplifying your `Model` example

```elm
type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    }
```

##### Take 1

```elm
type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    , minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
    }

input []
    [ value model.searchIn
    , onInput SetSearchIn
    ]
```

##### Take 2 with delegation

```elm
type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    , searchOptions : SearchOptionsModel
    }

type alias SearchOptionsModel =
    { minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
    }

input []
    [ value model.searchOptions.searchIn
    , onInput SetSearchIn
    ]
```

### How to simplify your `Msg`

Reduce the number of types in your `Msg`, by:

1. making a new `union type` (let's say `SearchOptionsMsg`) and,
2. adding it back into your `Msg` as a new type (let's say `| SearchOptions SearchOptionsMsg`)

It's like namespacing the `Msg`.

#### Simplifying your `Msg` example

```elm
type Msg
    = Search
    | SearchQuery String
    | DeleteById Int
```

##### Take 1

```elm
type Msg
    = Search
    | SearchQuery String
    | DeleteById Int
    | SetMinStars String
    | SetSearchIn String
    | SetUserFilter String

input []
    [ value model.searchOptions.searchIn
    , onInput SetSearchIn
    ]
```

##### Take 2 with delegation

```elm
type Msg
    = Search
    | SearchQuery String
    | DeleteById Int
    | SearchOptions SearchOptionsMsg

type SearchOptionsMsg
    = SetMinStars String
    | SetSearchIn String
    | SetUserFilter String

input []
    [ value model.searchOptions.searchIn
    , onInput (SearchOptions SetSearchIn)
    ]
```

### How to scope your `view` functions?

Aim for a narrower, more focused `view` functions:

- Do not accept an entire `Model` when possible.
- Do not return `Html Msg`, go for a scoped `Msg`.

Something like:

```elm
-- BEFORE
chunkOfView : Model -> Html Msg

-- AFTER
chunkOfView : ChunkOfModel -> Html MsgSubset
```

#### Scoping your `view` functions

```elm
type Msg = ...
type SearchOptionsMsg = ...

type alias Model = ...
type alias SearchOptionsModel = ...

viewOptions : Model -> Html Msg
viewOptions model =
    input []
        [ value model.searchOptions.searchIn
        , onInput (SearchOptions SetSearchIn)
        ]
```

##### Solution

```elm
type Msg = ...
type SearchOptionsMsg = ...          -- Scoped Msg

type alias Model = ...
type alias SearchOptionsModel = ...  -- A chunk of Model

viewOptions : SearchOptionsModel -> Html SearchOptionsMsg
viewOptions searchOptions =
    input []
        [ value searchOptions.searchIn
        , onInput SetSearchIn
        ]
```

### What is the downside for scoping your `view` functions?

A type mismatch:

```elm
viewSearchOptions : SearchOptionsModel -> Html SearchOptionsMsg
view              : Model              -> Html Msg
```

`view` can no longer use `viewSearchOptions` directly, because:

- `view` return type is `Html Msg`,
- `viewSearchOptions` return type is `Html SearchOptionsMsg`.

#### How can we fix the type mismatch problem?

Using `Html.map` with a `SearchOptionsMsg -> Msg` function.

#### Which `SearchOptionsMsg -> Msg` function?

The `SearchOptions SearchOptionsMsg` constructor from `Msg`

```elm
type Msg
    = ...
    | SearchOptions SearchOptionsMsg
```

### Fixing the type mismatch problem

```elm
type Msg = ... | SearchOptions SearchOptionsMsg

viewSearchResult : SearchResult -> Html Msg
viewSearchOptions : SearchOptionsModel -> Html SearchOptionsMsg

view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ ...
        , viewSearchOptions model.searchOptions  -- this produces the type mismatch
        , ul [] (model.results |> List.map viewSearchResults)
```

#### Solution

```elm
type Msg = ... | SearchOptions SearchOptionsMsg

viewSearchResult : SearchResult -> Html Msg
viewSearchOptions : SearchOptionsModel -> Html SearchOptionsMsg

view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ ...
        , (viewSearchOptions model.searchOptions) |> Html.map SearchOptions
        , ul [] (model.results |> List.map viewSearchResults)
```

### `map` galore!

```elm
List.map : (originalVal -> newVal) -> List originalVal -> List newVal
Html.map : (originalMsg -> newMsg) -> Html originalMsg -> Html newMsg
 Cmd.map : (originalMsg -> newMsg) ->  Cmd originalMsg ->  Cmd newMsg
 Sub.map : (originalMsg -> newMsg) ->  Sub originalMsg ->  Sub newMsg
```

### References

- [Html.map](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html#map)
